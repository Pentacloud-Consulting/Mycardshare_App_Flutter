"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Hero from "@/components/landing/Hero";
import ImpactSection from "@/components/landing/ImpactSection";
import DigitalSection from "@/components/landing/DigitalSection";
import DashboardMockup from "@/components/landing/DashboardMockup";
import SeamlessVideo from "@/components/landing/SeamlessVideo";
import NetworkFeatures from "@/components/landing/NetworkFeatures";
import AudienceSplit from "@/components/landing/AudienceSplit";
import IntelligenceSection from "@/components/landing/IntelligenceSection";
import CampaignSection from "@/components/landing/CampaignSection";
import BlogSection from "@/components/landing/BlogSection";
import Features from "@/components/landing/Features";
import HowItWorksFlow from "@/components/landing/HowItWorksFlow";
import CTA from "@/components/landing/CTA";

export default function HomeContent() {
  const { userData, loading } = useAuth();
  const router = useRouter();



  return (
    <>
      <Navbar />
      <main>
        <Hero />
        <ImpactSection />
        <SeamlessVideo />
        <Features />
        <HowItWorksFlow />
        <DigitalSection />
        <NetworkFeatures />
        <DashboardMockup />
        <AudienceSplit />
        <IntelligenceSection />
        <CampaignSection />
        <BlogSection />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
