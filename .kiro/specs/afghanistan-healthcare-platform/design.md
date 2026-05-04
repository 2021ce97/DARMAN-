# Design Document: MediConnect (HealthLink) Healthcare Platform

## Overview

MediConnect (HealthLink) is a comprehensive healthcare discovery and telemedicine platform for Afghanistan, designed to connect patients with healthcare providers (doctors, hospitals, diagnostic labs, and pharmacies) across all 34 provinces. The platform addresses Afghanistan's unique healthcare challenges: fragmented healthcare access, low digital literacy, limited internet connectivity, cash-based economy, and multilingual requirements (Dari, Pashto, English).

### System Context

The platform consists of three primary applications:

1. **Patient Mobile App** (Flutter) - Primary user-facing application for patients to discover providers, book appointments, manage health records, and access telemedicine
2. **Doctor Mobile App** (Flutter) - Provider application for doctors to manage schedules, consultations, prescriptions, and earnings
3. **Admin Web Dashboard** (Next.js) - Administrative portal for platform management, provider verification, analytics, and revenue tracking

### Key Design Principles

- **Offline-First**: Critical features must work without internet connectivity using local caching (Hive)
- **Low-Bandwidth Optimization**: Minimize data transfer, use progressive image loading, implement pagination
- **Cash-First with Digital Option**: Support cash payments as primary method with optional digital payments (HesabPay)
- **Multilingual**: Support Dari, Pashto, and English with RTL text direction
- **Security & Privacy**: HIPAA-inspired data protection with field-level encryption for sensitive medical data
- **Scalability**: Design for national rollout across 34 provinces with millions of users
- **Phased Rollout**: MVP in Kabul (Phase 1) → Hospital/Lab/Pharmacy + Telemedicine (Phase 2) → AI + Video + RTL (Phase 3) → Admin + Monetization + National (Phase 4)

## Architecture

### High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        PA[Patient Mobile App<br/>Flutter]
        DA[Doctor Mobile App<br/>Flutter]
        AW[Admin Web Dashboard<br/>Next.js]
    end
    
    subgraph "API Gateway Layer"
        AG[API Gateway<br/>Fastify + Node.js]
    end
    
    subgraph "Service Layer"
        AS[Auth Service]
        DS[Doctor Service]
        BS[Booking Service]
        CS[Consultation Service]
        LS[Lab Service]
        PS[Pharmacy Service]
        HS[Hospital Service]
        ES[EMR Service]
        PYS[Payment Service]
        SS[Search Service]
        AIS[AI Chatbot Service]
        SMS[SMS Service]
        NS[Notification Service]
    end
    
    subgraph "Data Layer"
        FS[(Firestore<br/>Primary DB)]
        PG[(PostgreSQL<br/>Analytics)]
        RD[(Redis<br/>Cache)]
        ST[Firebase Storage<br/>Files]
        HV[Hive<br/>Local Cache]
    end
    
    subgraph "External Services"
        FCM[Firebase Cloud<br/>Messaging]
        GM[Google Gemini<br/>AI API]
        AG_SDK[Agora SDK<br/>Video]
        HP[HesabPay<br/>Payments]
        OSM[OpenStreetMap<br/>Maps]
    end
    
    PA --> AG
    DA --> AG
    AW --> AG
    
    AG --> AS
    AG --> DS
    AG --> BS
    AG --> CS
    AG --> LS
    AG --> PS
    AG --> HS
    AG --> ES
    AG --> PYS
    AG --> SS
    AG --> AIS
    AG --> SMS
    AG --> NS
    
    AS --> FS
    DS --> FS
    BS --> FS
    CS --> FS
    LS --> FS
    PS --> FS
    HS --> FS
    ES --> FS
    PYS --> FS
    SS --> FS
    
    AS --> RD
    DS --> RD
    SS --> RD
    
    ES --> ST
    DS --> ST
    
    PA --> HV
    DA --> HV
    
    NS --> FCM
    AIS --> GM
    CS --> AG_SDK
    PYS --> HP
    PA --> OSM
