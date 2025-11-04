# 🏛️ Architectural Overview: A Cohesive, Real-Time Elixir System

**Objective:** This document outlines the technical architecture for a server-rendered, real-time web application built on the BEAM. The design prioritizes **high cohesion** and **low coupling** by centralizing the domain model in the Ash Framework and leveraging Phoenix LiveView for all presentation logic, eliminating the need for a separate SPA.

**Core Philosophy:** The system is designed around a "single source of truth" principle. The server is the definitive source for business logic, state, and rendering.
* **Ash Framework** defines the application's domain, resources, and business rules.
* **Phoenix LiveView** provides the rich, interactive user interface by managing a stateful process on the server for each connected client.
* **PostgreSQL** serves as the durable persistence layer, managed entirely via the Ash data layer.

---

### 1. Data Layer: Persistence

* **Technology:** PostgreSQL 18
* **Responsibility:** Durable, transactional, and consistent data storage.

This layer is the system's "foundation." It is treated as a persistence store and nothing more. All business logic, constraints (beyond basic `NOT NULL` or foreign keys), and access rules are defined in the Business Logic layer.

The application **does not** interact with PostgreSQL directly. All database interaction is abstracted and managed by the Ash Framework, which uses the `ash_postgres` extension to generate and execute optimized SQL queries. This decouples our domain logic from the specific database implementation.

---

### 2. Business & Application Logic: Ash Framework

* **Technology:** Ash Framework (Core, `ash_postgres`)
* **Responsibility:** The definitive source of truth for all domain entities, business logic, calculations, and authorization policies. This layer is the "brain" of the application.

Ash is not just an ORM; it is the declarative domain modeling layer. It entirely replaces the traditional Elixir pattern of scattered Ecto schemas, changesets, and context modules.

#### Key Responsibilities of Ash

* **Domain Modeling (Resources):**
    * Ash **Resources** are the central definition for all entities (e.g., `User`, `Post`, `Comment`).
    * A resource declaratively defines its `attributes` (fields), `relationships` (associations), and `identities` (primary keys).
    * This provides a single, co-located file to understand any given domain entity.

* **Business Logic (Actions):**
    * All state mutations are defined as explicit **Actions** on a resource (e.g., `:create`, `:update`, `:publish_post`, `:add_comment`).
    * Actions are the *only* way to change a resource's state.
    * They contain all **validations** and **changes** (business logic) for that specific operation. For example, the `:publish_post` action would contain the logic to set the `published_at` timestamp and validate that the `body` is not empty.

* **Authorization (Policies):**
    * Ash provides a powerful, built-in, and declarative authorization system.
    * **Policies** are attached directly to resources and actions, defining *who* can perform *what* action on *which* specific record.
    * This eliminates "sprinkled" permission checks. All authorization logic is centralized and enforced automatically on every Ash API call.

* **Data Access (The Ash API):**
    * Ash exposes a rich, consistent API for interacting with resources (e.g., `MyApp.Blog.create_post(...)`, `MyApp.Blog.read(MyApp.Blog.Post, ...)`).
    * The Presentation Layer (LiveView) uses this API exclusively. It **never** bypasses Ash to access the database.

---

### 3. Presentation Layer: Phoenix & LiveView

* **Technology:** Phoenix Framework, Phoenix LiveView, Tailwind CSS, daisyUI
* **Responsibility:** Rendering the user interface, handling all user interactions, and managing transient UI state.

This layer is concerned *only* with presentation. It is "dumb" about business rules and "smart" about user interaction.

* **Phoenix Framework (The Shell):**
    * Phoenix acts as the web server, handling HTTP endpoints, routing, and static asset delivery.
    * Its primary role is to serve the initial HTML request and establish the persistent **WebSocket** connection for Phoenix LiveView.
    * It also compiles and serves the static CSS bundle (Tailwind/daisyUI).

* **Phoenix LiveView (The Interactive Core):**
    * When a user hits a page, a dedicated **LiveView process** (a `GenServer`) is spawned on the server *for that user*.
    * This process holds the page's state in its `socket.assigns`. This state is ephemeral and UI-specific (e.g., form data, toggle states, search queries).
    * User interactions (clicks, form inputs) are sent as events over the WebSocket to this specific process.
    * `handle_event` callbacks in the LiveView receive these events.

* **Styling (Tailwind & daisyUI):**
    * These are **not** JS frameworks. They are CSS utilities and components.
    * They are compiled into a static `app.css` file by Phoenix's build system and served like any other static asset. They have no bearing on the server-side logic or data flow.

---

### 4. 🔄 Real-Time Data Flow: Lifecycle of an Interactive Event

This step-by-step example details how all layers work together when a user clicks a "Save" button on a form.

1.  **Client (Browser):** A user clicks a button on a form:
    `<button phx-click="save">Save Changes</button>`

2.  **Client (LiveView JS):** The LiveView JavaScript client (running in the browser) captures this `phx-click` event. It serializes the relevant form data and sends a message (e.g., `{"event": "save", "payload": ...}`) over the persistent WebSocket connection to the server.

3.  **Server (LiveView Process):** The user's dedicated LiveView process receives the message and invokes the corresponding callback:
    `def handle_event("save", %{"form_data" => data}, socket)`

4.  **Server (Presentation -> Business Logic):** Inside `handle_event`, the LiveView **does not** perform logic. It immediately delegates to the Ash API, passing the `data` and the `current_user` (for authorization):
    `MyApp.Blog.update_post(socket.assigns.post, data, actor: socket.assigns.current_user)`

5.  **Server (Business Logic - Authorization):** The Ash API intercepts this call. It first checks the policies on the `Post` resource. "Is this `current_user` allowed to perform the `:update_post` action on this specific `post` record?"
    * If **No**: Ash returns an `{:error, ...}` tuple, which the LiveView handles (e.g., showing a "Permission Denied" flash).
    * If **Yes**: The action proceeds.

6.  **Server (Business Logic - Action):** Ash executes the `:update_post` action.
    * It applies the changes from the `data` payload.
    * It runs all **validations** defined for the action.
    * If invalid, it returns `{:error, changeset}`, which the LiveView uses to render validation messages.
    * If valid, it runs any other logic in the action (e.g., setting an `updated_at` timestamp).

7.  **Server (Business Logic -> Data Layer):** Ash's `ash_postgres` data layer translates the validated action into an SQL `UPDATE` statement and executes it against the PostgreSQL database within a transaction.

8.  **Server (Data Layer -> Business Logic):** PostgreSQL returns the updated record to Ash.

9.  **Server (Business Logic -> Presentation):** The Ash API returns the successful result to the LiveView:
    `{:ok, updated_post}`

10. **Server (Presentation - State Update):** The LiveView's `handle_event` function receives the `{:ok, updated_post}`. It updates its own state by modifying the `socket.assigns`:
    `socket = assign(socket, :post, updated_post)`
    `socket = put_flash(socket, :info, "Post updated successfully!")`

11. **Server (Presentation - Render & Diff):** Because the `socket.assigns` changed, the LiveView automatically re-renders its HEEx template *in memory* using the new state. Phoenix's "diff" engine calculates the minimal set of HTML changes between the old and new render.

12. **Server (LiveView -> Client):** This tiny diff (e.g., `Update "Post Title", add <div class="flash">...`) is sent back to the client over the WebSocket.

13. **Client (LiveView JS):** The LiveView JavaScript client receives the diff and "morphs" the browser's DOM to match the new state. The user sees the success message and their changes instantly, without a full page reload.

---

### 5. Component Diagram & Responsibilities

To visualize this flow, consider the following component relationships.



* **Browser:** Runs the lightweight LiveView JS client. Manages the WebSocket and DOM patching.
* **Phoenix Endpoint:** The server's entrypoint. Terminates the WebSocket and routes traffic to the correct LiveView Process.
* **LiveView Process:** A stateful `GenServer` (one per user/page). Handles UI events and calls the Ash API. **Responsibility: UI State & Interaction.**
* **Ash API:** The Elixir code interface for the domain (e.g., `MyApp.Blog`). **Responsibility: Public interface for the domain.**
* **Ash Resource:** The declarative definition of an entity, its actions, and its policies. **Responsibility: Domain logic, business rules, and authorization.**
* **Ash Data Layer (`ash_postgres`):** The implementation detail that translates Ash actions into SQL. **Responsibility: Database abstraction.**
* **PostgreSQL:** The database engine. **Responsibility: Durable data storage.**

