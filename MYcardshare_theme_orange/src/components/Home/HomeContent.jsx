"use client";

import React from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

import HeroSection from "@/components/Home/HeroSection";
import MaximumImpact from "@/components/Home/MaximumImpact";
import MarketingVideo from "@/components/Home/MarketingVideo";
import MyCardShare from "@/components/Home/mycardshare";
import Wallets from "@/components/Home/Wallets";
import NetworkIntelligence from "@/components/Home/NetworkIntelligence";
import FlipBookFeatures from "@/components/Home/FlipBookFeatures";
import AnalyticsDashboard from "@/components/Home/AnalyticsDashboard";
import TailoredForYou from "@/components/Home/TailoredForYou";
import OurProduct from "@/components/Home/OurProduct";
import BlogSection from "@/components/Home/BlogSection";
import CTA from "@/components/Home/CTA";
import AppStoreModal from "@/components/Home/AppStoreModal";

export default function HomeContent() {
  return (
    <>
      {/* Existing Platform Navbar */}
      <Navbar />

      {/* Main Home Sections */}
      <main>
        {/* Hero Section with Arrangement from Image 3 & Theme from Image 4 */}
        <HeroSection />

        {/* Engineered for Maximum Impact Bento Section (Image 1 Layout + Image 2 Content) */}
        <MaximumImpact />

        {/* Marketing Video Section (Image 1 Design + Image 2 Information) */}
        <MarketingVideo />

        {/* Infinite Interactive Marquee: "MY CARD SHARE" */}
        <MyCardShare />

        {/* Digital Wallet Pass Parallax Showcase */}
        <Wallets />

        {/* Network Intelligence - Build Your Network Seamlessly (Image 1) */}
        <NetworkIntelligence />

        {/* 3D FlipBook Features Section */}
        <FlipBookFeatures />

        {/* Analytics & Reporting Dashboard Section (From Reference Image) */}
        <AnalyticsDashboard />

        {/* Tailored For You - Built For Everyone, Individuals & Enterprises (Image 2) */}
        <TailoredForYou />

        {/* Cinematic Slice Product Showcase (New Section) */}
        <OurProduct />

        {/* Minimalist Editorial Magazine Journal */}
        <BlogSection />

        {/* High-Conversion App CTA Banner (Image 1 Design + Overlapping Mobile Asset) */}
        <CTA />
      </main>

      {/* Existing Platform Footer */}
      <Footer />

      {/* App Store Coming Soon Modal */}
      <AppStoreModal />
    </>
  );
}
