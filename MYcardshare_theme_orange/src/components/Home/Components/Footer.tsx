"use client";

import React from "react";
import Link from "next/link";
import { Phone, Mail } from "lucide-react";

export default function Footer() {
  const currentYear = 2026;

  const productLinks = [
    { label: "Features", href: "#features" },
    { label: "Pricing", href: "#pricing" },
    { label: "Enterprise", href: "#enterprise" },
    { label: "Blog", href: "#blog" },
  ];

  const companyLinks = [
    { label: "About Us", href: "#about" },
    { label: "Contact", href: "#contact" },
    { label: "Privacy", href: "#privacy" },
    { label: "Terms", href: "#terms" },
  ];

  const resourceLinks = [
    { label: "Documentation", href: "#docs" },
    { label: "API", href: "#api" },
    { label: "Security", href: "#security" },
    { label: "Status", href: "#status" },
  ];

  return (
    <footer className="relative w-full bg-white text-neutral-800 pt-16 sm:pt-20 pb-12 overflow-hidden border-t border-neutral-100">
      <div className="max-w-7xl mx-auto px-6 sm:px-8 lg:px-12">
        {/* Top Grid: Brand & Link Columns */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 lg:gap-12 pb-16">
          {/* Brand Info & Contacts (Spans 2 columns on lg) */}
          <div className="lg:col-span-2 flex flex-col gap-6">
            <Link href="/" className="flex items-center gap-2.5 group">
              <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-gradient-to-tr from-[#D4642C] to-[#F18F58] text-white shadow-xs transition-transform duration-300 group-hover:scale-105">
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className="w-5 h-5"
                >
                  <rect x="2" y="5" width="20" height="14" rx="3" />
                  <line x1="2" y1="10" x2="22" y2="10" />
                  <line x1="6" y1="15" x2="8" y2="15" />
                  <path d="M16 3a4 4 0 0 1 4 4" />
                  <path d="M19 1a7 7 0 0 1 4 4" />
                </svg>
              </div>
              <div className="flex items-center">
                <span className="text-xl font-bold tracking-tight text-neutral-900">
                  MyCard
                </span>
                <span className="text-xl font-bold tracking-tight text-[#D4642C]">
                  Share
                </span>
              </div>
            </Link>

            <p className="text-sm leading-relaxed text-neutral-500 max-w-sm">
              The seamless way to create and share digital business cards. Elevate your professional identity and network anywhere with absolute confidence.
            </p>

            <div className="flex flex-col gap-3.5 pt-2">
              <a
                href="tel:+971545132807"
                className="inline-flex items-center gap-3 text-sm text-neutral-700 hover:text-[#D4642C] transition-colors group"
              >
                <div className="flex items-center justify-center w-8 h-8 rounded-full bg-[#FAF6F2] group-hover:bg-[#FDF2EB] text-neutral-600 group-hover:text-[#D4642C] transition-colors border border-[#EFE8E1]">
                  <Phone className="w-4 h-4" />
                </div>
                <span>+971 545 132 807</span>
              </a>

              <a
                href="mailto:contactus@pentacloudconsulting.com"
                className="inline-flex items-center gap-3 text-sm text-neutral-700 hover:text-[#D4642C] transition-colors group"
              >
                <div className="flex items-center justify-center w-8 h-8 rounded-full bg-[#FAF6F2] group-hover:bg-[#FDF2EB] text-neutral-600 group-hover:text-[#D4642C] transition-colors border border-[#EFE8E1]">
                  <Mail className="w-4 h-4" />
                </div>
                <span>contactus@pentacloudconsulting.com</span>
              </a>
            </div>
          </div>

          {/* Product Links */}
          <div className="flex flex-col gap-4">
            <h4 className="text-sm font-bold uppercase tracking-wider text-neutral-900">
              Product
            </h4>
            <ul className="flex flex-col gap-2.5">
              {productLinks.map((item) => (
                <li key={item.label}>
                  <Link
                    href={item.href}
                    className="text-sm text-neutral-500 hover:text-[#D4642C] transition-colors"
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Company Links */}
          <div className="flex flex-col gap-4">
            <h4 className="text-sm font-bold uppercase tracking-wider text-neutral-900">
              Company
            </h4>
            <ul className="flex flex-col gap-2.5">
              {companyLinks.map((item) => (
                <li key={item.label}>
                  <Link
                    href={item.href}
                    className="text-sm text-neutral-500 hover:text-[#D4642C] transition-colors"
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources Links */}
          <div className="flex flex-col gap-4">
            <h4 className="text-sm font-bold uppercase tracking-wider text-neutral-900">
              Resources
            </h4>
            <ul className="flex flex-col gap-2.5">
              {resourceLinks.map((item) => (
                <li key={item.label}>
                  <Link
                    href={item.href}
                    className="text-sm text-neutral-500 hover:text-[#D4642C] transition-colors"
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Big Watermark Banner: MYCARDSHARE with divider and animated pulsing dot */}
        <div className="relative my-8 sm:my-12 flex flex-col items-center justify-center select-none overflow-hidden">
          <div className="text-[13vw] sm:text-[11vw] md:text-[9.5vw] font-black tracking-tight uppercase leading-none whitespace-nowrap bg-clip-text text-transparent bg-gradient-to-r from-stone-200/90 via-[#D4642C] via-50% to-stone-200/90 animate-footer-sweep opacity-85 transition-opacity">
            MYCARDSHARE
          </div>

          {/* Horizontal Line with Center Dot */}
          <div className="w-full relative flex items-center justify-center mt-[-2vw] sm:mt-[-1.5vw]">
            <div className="w-full h-px bg-neutral-200" />
            <div className="absolute w-3.5 h-3.5 rounded-full bg-white border-2 border-[#D4642C] flex items-center justify-center">
              <span className="absolute inset-0 rounded-full bg-[#D4642C]/30 animate-ping opacity-60" />
              <span className="w-1.5 h-1.5 rounded-full bg-[#D4642C] animate-footer-dot" />
            </div>
          </div>
        </div>

        {/* Bottom Bar: Copyright, Social Icons, Legal */}
        <div className="pt-6 flex flex-col sm:flex-row items-center justify-between gap-6">
          {/* Copyright */}
          <p className="text-xs sm:text-sm text-neutral-500 order-2 sm:order-1 text-center sm:text-left">
            &copy; {currentYear} My Card Share. All rights reserved.
          </p>

          {/* Social Icons (Exact Circular Bordered Icons from Image 2) */}
          <div className="flex items-center gap-3 order-1 sm:order-2">
            {/* LinkedIn */}
            <a
              href="https://www.linkedin.com/company/pentacloudconsulting/"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="LinkedIn"
              className="w-9 h-9 rounded-full border border-neutral-200 flex items-center justify-center text-neutral-500 hover:text-[#D4642C] hover:border-[#D4642C] hover:bg-[#FAF6F2] transition-all duration-200 hover:scale-105"
            >
              <svg className="w-4 h-4 fill-currentColor" viewBox="0 0 24 24">
                <path d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.28 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.75M6.46 8.76a1.6 1.6 0 0 0 1.6-1.6c0-.88-.72-1.6-1.6-1.6a1.6 1.6 0 0 0-1.6 1.6c0 .88.72 1.6 1.6 1.6m1.4 9.74v-8.37H5.06v8.37h2.8z" />
              </svg>
            </a>

            {/* Instagram */}
            <a
              href="https://www.instagram.com/pentacloudconsulting/"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Instagram"
              className="w-9 h-9 rounded-full border border-neutral-200 flex items-center justify-center text-neutral-500 hover:text-[#D4642C] hover:border-[#D4642C] hover:bg-[#FAF6F2] transition-all duration-200 hover:scale-105"
            >
              <svg className="w-4 h-4 fill-currentColor" viewBox="0 0 24 24">
                <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z" />
              </svg>
            </a>

            {/* Facebook */}
            <a
              href="https://www.facebook.com/profile.php?id=61573242994665&mibextid=wwXIfr&rdid=a9vdt4aEsAkRZwBi&share_url=https%3A%2F%2Fwww.facebook.com%2Fshare%2F1CP9RauVy6%2F%3Fmibextid%3DwwXIfr#"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Facebook"
              className="w-9 h-9 rounded-full border border-neutral-200 flex items-center justify-center text-neutral-500 hover:text-[#D4642C] hover:border-[#D4642C] hover:bg-[#FAF6F2] transition-all duration-200 hover:scale-105"
            >
              <svg className="w-4 h-4 fill-currentColor" viewBox="0 0 24 24">
                <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
              </svg>
            </a>

            {/* X / Twitter */}
            <a
              href="https://x.com/pentacloudind?s=21"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Twitter"
              className="w-9 h-9 rounded-full border border-neutral-200 flex items-center justify-center text-neutral-500 hover:text-[#D4642C] hover:border-[#D4642C] hover:bg-[#FAF6F2] transition-all duration-200 hover:scale-105"
            >
              <svg className="w-3.5 h-3.5 fill-currentColor" viewBox="0 0 24 24">
                <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
              </svg>
            </a>
          </div>

          {/* Legal Links */}
          <div className="flex items-center gap-4 text-xs sm:text-sm text-neutral-500 order-3">
            <Link
              href="#terms"
              className="hover:text-[#D4642C] transition-colors"
            >
              Terms of Service
            </Link>
            <span className="text-neutral-300">|</span>
            <Link
              href="#privacy"
              className="hover:text-[#D4642C] transition-colors"
            >
              Privacy Policy
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
