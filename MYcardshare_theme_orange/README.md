# Pentacloud DBC² Nexus

**Pentacloud DBC² Nexus** is a state-of-the-art Digital Business Card (DBC) platform designed for the era of professional decentralization. Built with high-fidelity aesthetics and enterprise-grade scalability, it allows individuals and organizations to serialize their professional identity and share it seamlessly via NFC, QR, or sovereign links.

## 🚀 Key Features

- **Dynamic Identity Profiles**: Create stunning, mobile-responsive digital cards with custom banner art and interactive sections.
- **Enterprise-Grade Dashboard**: Manage workforce cards, analyze engagement stats, and maintain brand consistency from a unified portal.
- **Smart Contact Sharing**: Seamlessly export contacts, share via NFC taps, or integrate directly with CRM systems.
- **AI-Search Ready (AEO)**: Fully optimized for Google SGE, Perplexity, and LLM-based discovery using advanced JSON-LD structured data.
- **NEXUS v3 Design System**: Premium "Midnight Aurora" dark-mode aesthetic featuring fluid animations and glassmorphism.
- **Modern Security**: Sovereign authentication powered by Firebase with secure API adapters.

## 🛠️ Tech Stack

- **Framework**: [Next.js 15+](https://nextjs.org/) (App Router Strategy)
- **Styling**: Vanilla CSS + Tailwind CSS 4.0 (for layout utilities)
- **Animation**: [Framer Motion v12](https://www.framer.com/motion/)
- **Backend / Auth**: Firebase SDK (Web + Admin)
- **Database**: MongoDB (via `mongodb` native driver)
- **Discovery**: [JSON-LD](https://json-ld.org/) Structured Data, Custom `llms.txt`, and Dynamic Sitemaps.
- **Icons**: [Lucide React](https://lucide.dev/)

## 📂 Project Structure

```bash
├── src/
│   ├── app/           # Next.js 15 App Router (Routes & APIs)
│   ├── backend/       # Core server logic, services, and middleware
│   ├── components/    # Atomic UI library and NEXUS component system
│   ├── lib/           # Shared utilities (Schema, Auth, Config)
│   └── data/          # Static data structures and retreat assets
├── public/            # Optimized assets and user uploads
└── package.json       # Project dependencies and workspace scripts
```

## ⚡ Getting Started

### Prerequisites

- Node.js 18+
- Firebase Project setup
- MongoDB Instance

### Installation

1. Clone the repository:
   ```bash
   git clone [repository-url]
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables:
   Create a `.env` file in the root with your Firebase and MongoDB credentials.

### Development

Run the development server:

```bash
npm run dev
```

### Build

Create an optimized production bundle:

```bash
npm run build
```

## 📈 SEO & Optimization

The platform implements **AEO (Answer Engine Optimization)** best practices:

- **Organization Schema**: Applied globally to root layout.
- **Person Schema**: Dynamically injected on every individual card profile.
- **BreadcrumbList & FAQ**: Enhancing search snippet rich results.
- **Machine Readability**: Specialized `llms.txt` for AI crawler consumption.

---

Built with ❖ by **Antigravity** as part of the NEXUS project.

by Saad
