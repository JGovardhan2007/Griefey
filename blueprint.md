# Project Blueprint: Griefey

## Overview

Griefey is a Flutter-based mobile and web application designed to be a comprehensive grievance redressal system. It provides a platform for users to submit, track, and manage grievances, while also offering an administrative backend for staff to review, update, and resolve these issues. The application is built with a focus on modern design, a responsive user experience, and a robust, scalable architecture using Firebase for its backend services.

## Implemented Features & Design

### 1. Architecture & Core Libraries

*   **Decoupled Authentication:** The app uses a provider-based architecture with a dedicated `AuthService` (`lib/auth_service.dart`). This service encapsulates all Firebase Authentication logic, separating it cleanly from the UI. This is the industry best practice, providing testability and maintainability.
*   **Declarative Routing with `go_router`:** Navigation is handled by the `go_router` package. The routing logic (`lib/app_router.dart`) is authentication-aware, automatically redirecting users based on their login status. This is achieved by injecting the `AuthService` into the router.
*   **State Management with `Provider`:** The `provider` package is used for dependency injection (providing the `AuthService`) and for managing app-wide state, such as the theme.
*   **Environment-Specific Firebase Config:** The app correctly uses different Firebase configurations for web (`localhost` for development) and mobile, ensuring smooth local development without CORS issues.

### 2. Authentication Flow

*   **Email & Password Authentication:** Users can sign up for a new account with their name, email, and password, or sign in with existing credentials.
*   **Specific Error Handling:** The login and sign-up screens provide clear, user-friendly error messages for common issues like incorrect passwords, non-existent users, or weak passwords. This is managed centrally in the `AuthService`.
*   **Secure User Data Storage:** Upon registration, user details (name, email, creation date, and admin status) are securely stored in a `users` collection in Firestore, linked by the user's unique Firebase UID.
*   **Role-Based Access Control (RBAC):** The system supports an `isAdmin` flag on user documents and leverages Firebase Auth custom claims to differentiate between regular users and administrators.

### 3. User Interface & Design

*   **Modern Material 3 Design:** The application adheres to Material 3 design principles, using `ThemeData` to define a consistent and modern look and feel.
*   **Custom Theming:** A centralized theme (`lib/theme_provider.dart`) defines color schemes, typography (using `GoogleFonts`), and component styles for both light and dark modes.
*   **Responsive UI:** The layout is designed to be responsive, working well on both mobile devices and larger web screens.
*   **Polished Components:**
    *   **Cards with Elevation:** Grievance list items use `Card` widgets with elevation for a clean, layered look.
    *   **Interactive FAB:** The "Submit Grievance" Floating Action Button includes a subtle hover animation for a better user experience on web.
    *   **Status Chips:** Grievances are displayed with color-coded status chips (Pending, In-Progress, Resolved) for quick visual identification.
    *   **Empty State:** A helpful and visually appealing empty state is shown on the home screen when a user has not yet submitted any grievances.

### 4. Grievance Management

*   **Real-time Grievance List:** The home screen displays a real-time list of the user's grievances using a `StreamBuilder` connected to a Firestore query.
*   **Grievance Submission:** Users can navigate to a dedicated screen to submit a new grievance, including a title, category, and other details.
*   **Grievance Details:** Tapping on a grievance in the list navigates the user to a details screen where they can view more information.
*   **Admin Dashboard:** An admin-only dashboard is accessible to users with the `admin` custom claim, allowing them to view and manage all user grievances.

---

## Current Plan: Project Documentation

*   **Action:** Create a comprehensive `blueprint.md` file.
*   **Purpose:** To document the application's current architecture, features, and design decisions. This serves as a single source of truth for the project's state, facilitating future development, onboarding of new developers, and ensuring consistency.
*   **Status:** Completed.
