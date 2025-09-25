# Griefey - Smart Grievance Redressal System

## Overview

Griefey is a mobile application that allows citizens to submit grievances to the concerned authorities and track their resolution in real-time. This document outlines the plan for the development of the user-facing mobile app.

## Features

- **User Authentication:** Email/phone-based signup and login with OTP/email-password.
- **Grievance Submission:** Submit grievances with a title, category, description, and multimedia attachments.
- **Real-time Status Tracking:** Track the status of submitted grievances with color-coded tags (Pending, In-Progress, Resolved).
- **Complaint Details:** View detailed information about each complaint, including a timeline of status updates.
- **User Profile:** Manage user details and application settings.
- **Push Notifications:** Receive notifications on status updates.
- **Offline Mode:** Save draft grievances and automatically upload them when an internet connection is available.

## Style and Design

- **UI:** Clean, modern, and responsive design using Material Design 3.
- **Fonts:** Expressive and relevant typography using `google_fonts`.
- **Colors:** A vibrant color palette with color-coded statuses.
- **Icons:** Intuitive icons for categories and actions.
- **Interactivity:** Modern and interactive UI components with a premium feel.

## Plan

1.  **Project Setup:**
    *   Create a `blueprint.md` file.
    *   Add necessary dependencies: `go_router`, `google_fonts`, `provider`.
2.  **Splash Screen:**
    *   Create a splash screen with the app logo and name.
3.  **Onboarding (Login/Signup):**
    *   Create the UI for the login and signup screens.
4.  **Home Screen:**
    *   Create the home screen with a "Submit Grievance" button and a list of mock grievances.
5.  **Submit Grievance Screen:**
    *   Create the form for submitting a new grievance.
6.  **Complaint Details Screen:**
    *   Create a screen to show the details of a selected complaint.
7.  **Profile Screen:**
    *   Create a basic profile screen.
8.  **Navigation:**
    *   Set up routing using `go_router`.
9.  **Theming:**
    *   Implement a custom theme with light and dark modes using `provider`.
10. **Backend Integration (Mock):**
    *   Use mock data for now, with a clear structure for future backend integration.
