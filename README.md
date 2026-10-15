
# foodlink

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# FoodLink – Smart Food Donation & Rescue App

FoodLink is a mobile application designed to reduce food waste by connecting food donors with NGOs and welfare organizations. It provides a simple way to share surplus food and help ensure that usable food reaches people in need.

## Objectives

- Reduce food waste in local communities.
- Connect food donors with NGOs and welfare organizations.
- Make food donation and pickup coordination easier.
- Prioritize donations according to remaining safe-use time and pickup feasibility.
- Promote community support and responsible food management.

## User Roles

**1. Donor:** Individuals, households, restaurants, bakeries, and shops can share surplus food and manage their donations.

**2. NGO / Welfare Organization:** NGOs can browse available food donations and request pickups to distribute food to people in need.

**3. Administrator:** The administrator monitors users, donations, and overall platform activity.

## Key Features

- User-friendly welcome and role selection screens.
- Donor dashboard for managing food donations.
- Food donation submission and management.
- NGO donation browsing and pickup requests.
- Donation status tracking.
- Basic administration and monitoring.
- Urgency-based donation prioritization to help prevent food from going to waste.

## Technology

FoodLink is being developed using Flutter and Dart. The application focuses on a simple, responsive interface and is initially being tested in a web browser. Backend and database integration are planned for a later development phase.

## Project Vision

FoodLink aims to create a practical connection between surplus food and people who need it. By simplifying donation and pickup coordination, the application seeks to reduce avoidable food waste and support local communities.

**Project Status:** Currently under development as part of a Mobile Application Development academic project.

## Current Demo Scope

The implemented donor workflow uses a local in-memory repository for sign-in,
profiles, donations, and pickup requests. New accounts and changes are lost
when the app process restarts. The demo account is `donor@foodlink.demo` with
password `Pass1234`.

The application has no Firebase initialization or Firebase dependencies. Its
authentication and data operations use local mock accounts and in-memory
repositories; data is not persistent or production-secure.

The shared role model supports Donor, NGO, and Admin accounts. This checkout
implements the Donor workspace; NGO and Admin workspaces must be supplied by
their respective implementations before those roles can use dashboard features.

