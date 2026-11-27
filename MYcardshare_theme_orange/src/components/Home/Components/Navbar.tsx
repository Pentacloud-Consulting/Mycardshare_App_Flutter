"use client";

import React, { useState } from "react";
import Link from "next/link";
import { Zap, Menu, X } from "lucide-react";

export interface NavbarProps {
  activeTab?: string;
}

export default function Navbar({ activeTab = "Home" }: NavbarProps) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const navLinks = [
    { label: "Home", href: "/" },
    { label: "Pricing", href: "#pricing" },
    { label: "Blog", href: "#blog" },
    { label: "Contact", href: "#contact" },
  ];

  return (
    <header className="absolute top-0 inset-x-0 z-50 w-full px-4 sm:px-6 lg:px-8 pt-4 sm:pt-6 transition-all duration-300">
      <div className="max-w-7xl mx-auto">
        <nav className="flex items-center justify-between px-5 sm:px-6 py-2.5 sm:py-3 bg-white/90 backdrop-blur-md rounded-full shadow-[0_4px_24px_rgba(0,0,0,0.06)] border border-[#EBE3DB]/80">
          {/* Brand Logo */}
          <Link href="/" className="flex items-center gap-2.5 group">
            <div className="relative flex items-center justify-center w-10 h-10 rounded-xl bg-gradient-to-tr from-[#D4642C] to-[#F18F58] text-white shadow-xs transition-transform duration-300 group-hover:scale-105">
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

          {/* Center Navigation Links (Pill Style from Image 1) */}
          <div className="hidden md:flex items-center gap-1.5 p-1 bg-[#FAF6F2] rounded-full border border-[#EFE8E1]">
            {navLinks.map((link) => {
              const isActive = activeTab === link.label;
              return (
                <Link
                  key={link.label}
                  href={link.href}
                  className={`px-5 py-1.5 text-sm font-medium rounded-full transition-all duration-200 ${
                    isActive
                      ? "bg-white text-[#D4642C] font-semibold shadow-xs"
                      : "text-neutral-600 hover:text-neutral-900 hover:bg-white/60"
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
          </div>

          {/* Right Action Buttons */}
          <div className="hidden sm:flex items-center gap-4">
            <Link
              href="#signin"
              className="text-sm font-semibold text-neutral-700 hover:text-[#D4642C] transition-colors duration-200 px-3 py-2"
            >
              Sign In
            </Link>

            <Link
              href="#join"
              className="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold text-white bg-gradient-to-r from-[#D4642C] to-[#E2763E] hover:from-[#C35620] hover:to-[#D4642C] rounded-full shadow-[0_4px_14px_rgba(212,100,44,0.35)] transition-all duration-300 hover:shadow-[0_6px_20px_rgba(212,100,44,0.45)] hover:-translate-y-0.5 active:translate-y-0"
            >
              <Zap className="w-4 h-4 fill-white text-white" />
              <span>Join My Card Share</span>
            </Link>
          </div>

          {/* Mobile Menu Toggle Button */}
          <div className="flex md:hidden items-center gap-2">
            <Link
              href="#join"
              className="sm:hidden inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-white bg-[#D4642C] rounded-full shadow-xs"
            >
              <Zap className="w-3.5 h-3.5 fill-white" />
              <span>Join</span>
            </Link>

            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              type="button"
              className="p-2 rounded-full text-neutral-700 hover:text-neutral-900 hover:bg-neutral-100 transition-colors"
              aria-label="Toggle menu"
            >
              {mobileMenuOpen ? (
                <X className="w-6 h-6" />
              ) : (
                <Menu className="w-6 h-6" />
              )}
            </button>
          </div>
        </nav>

        {/* Mobile Dropdown Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden mt-2 p-5 bg-white/95 backdrop-blur-lg rounded-2xl shadow-xl border border-[#EBE3DB] animate-in fade-in slide-in-from-top-2 duration-200">
            <div className="flex flex-col gap-2">
              {navLinks.map((link) => {
                const isActive = activeTab === link.label;
                return (
                  <Link
                    key={link.label}
                    href={link.href}
                    onClick={() => setMobileMenuOpen(false)}
                    className={`px-4 py-2.5 text-sm font-medium rounded-xl transition-all ${
                      isActive
                        ? "bg-[#FAF6F2] text-[#D4642C] font-semibold"
                        : "text-neutral-700 hover:bg-neutral-50"
                    }`}
                  >
                    {link.label}
                  </Link>
                );
              })}

              <div className="pt-4 mt-2 border-t border-neutral-100 flex flex-col gap-2.5">
                <Link
                  href="#signin"
                  onClick={() => setMobileMenuOpen(false)}
                  className="w-full text-center py-2.5 text-sm font-semibold text-neutral-700 hover:text-[#D4642C] rounded-xl hover:bg-neutral-50 transition-colors"
                >
                  Sign In
                </Link>
                <Link
                  href="#join"
                  onClick={() => setMobileMenuOpen(false)}
                  className="w-full flex items-center justify-center gap-2 py-3 text-sm font-semibold text-white bg-[#D4642C] hover:bg-[#C35620] rounded-xl shadow-md transition-colors"
                >
                  <Zap className="w-4 h-4 fill-white" />
                  <span>Join My Card Share</span>
                </Link>
              </div>
            </div>
          </div>
        )}
      </div>
    </header>
  );
}
