# FoodLink – Smart Food Donation & Rescue App

FoodLink is a mobile application designed to reduce food waste by connecting food donors with NGOs and welfare organizations. It provides a simple way to share surplus food and help ensure that usable food reaches people in need.

## Objectives

- Reduce food waste in local communities.
- Connect food donors with NGOs and welfare organizations.
- Make food donation and pickup coordination easier.
- Prioritize donations according to remaining safe-use time and pickup feasibility.
- Promote community support and responsible food management.

## User Roles

### 1. Donor
Individuals, households, restaurants, bakeries, and shops can share surplus food and manage their donations.

### 2. NGO / Welfare Organization
NGOs can browse available food donations and request pickups to distribute food to people in need.

### 3. Administrator
The administrator monitors users, donations, pickup requests, and overall platform activity.

## Key Features

- User-friendly welcome and role selection screens.
- Role-based login for Donors, NGOs, and Administrators.
- Donor dashboard for managing food donations.
- Food donation submission and management.
- NGO dashboard for browsing available donations.
- NGO pickup requests and donor approval or rejection.
- Donation status tracking and reservation after approval.
- NGO profile information and description.
- Basic administration and monitoring.
- Urgency-based donation prioritization to help prevent food from going to waste.
- Temporary signup accounts for new Donors and NGOs.

## Technology

- **Framework:** Flutter
- **Programming Language:** Dart
- **Development Environment:** Visual Studio Code
- **Initial Testing Platform:** Web browser
- **Data Storage:** Local in-memory repository for the current demo

Backend and database integration may be added in a later development phase.

## Demo Credentials

Use the following predefined accounts to test role-based authentication.

| Role    | Email                   | Password   |
|---------|-------------------------|------------|
| Donor 1 | `iqtedaronor@gmail.com` | `Pass12345`|
| Donor 2 | `adeeldonor@gmail.com`  | `Pass12345`|
| NGO 1   | `iqtedarNGO@gmail.com`  | `Pass1234` |
| NGO 2   | `adeelNGO@gmail.com`    | `Pass1234` |
| Admin   | `admin@gmail.com`       | `Admin@12345`|

### Account Behavior

- **Donor accounts:** Log in to access the Donor Dashboard and manage food donations and pickup requests.
- **NGO accounts:** Log in to access the NGO Dashboard, browse available donations, and request pickups.
- **Administrator account:** Log in to access the Admin Dashboard and monitor users, donations, and pickup requests.
- **New Donor and NGO accounts:** Users can register through the signup screen. Newly registered accounts remain available after logout while the app process is running, but are lost when the app process completely stops and restarts.
- **Admin registration:** Public signup is not allowed for administrator accounts. Additional Admin accounts may only be created by an authenticated administrator if that functionality is implemented.

The predefined demo accounts are intended to be initialized whenever the application starts, so they remain available after an application restart.

## Current Demo Scope

FoodLink currently uses a local in-memory repository for demo authentication and application data. Predefined accounts are initialized at startup, while newly registered accounts and other in-memory data are temporary.

The application does not currently require Firebase or a remote backend for its local demo workflow. Authentication and data operations are intended for academic demonstration and are not production-secure.

## Project Vision

FoodLink aims to create a practical connection between surplus food and people who need it. By simplifying donation and pickup coordination, the application seeks to reduce avoidable food waste and support local communities.

## Project Status

FoodLink is under development as part of a Mobile Application Development academic project. The current implementation focuses on role-based workflows, a responsive interface, and local demonstration data. Backend and database integration are planned for a later development phase.

## Security Notice

The credentials listed above are for academic demonstration only. They must not be used for real accounts or sensitive information. Production deployment would require secure authentication, password hashing, proper authorization, and persistent data storage.