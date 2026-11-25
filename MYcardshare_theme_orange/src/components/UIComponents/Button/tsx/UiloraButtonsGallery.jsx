"use client";

import React from "react";
import UiloraModernButtons from "@/components/UIComponents/Button/tsx/UiloraModernButtons";
import UiloraActionButtons from "@/components/UIComponents/Button/tsx/UiloraActionButtons";
import UiloraInteractiveButtons from "@/components/UIComponents/Button/tsx/UiloraInteractiveButtons";
import UiloraUtilityButtons from "@/components/UIComponents/Button/tsx/UiloraUtilityButtons";

export default function UiloraButtonsGallery() {
  return (
    <div className="min-h-screen bg-[#050505] text-white p-8 md:p-12 font-sans selection:bg-indigo-500/30 overflow-hidden">
      <div className="max-w-7xl mx-auto space-y-24">
        {/* Modern & SaaS Style */}
        <section className="space-y-6">
          <div className="flex items-center gap-4">
            <div className="h-px flex-1 bg-white/5" />
            <h2 className="text-xs font-mono text-zinc-500 uppercase tracking-[0.3em]">
              Modern & SaaS View
            </h2>
            <div className="h-px flex-1 bg-white/5" />
          </div>
          <UiloraModernButtons />
        </section>

        {/* Visual Actions */}
        <section className="space-y-6">
          <div className="flex items-center gap-4">
            <div className="h-px flex-1 bg-white/5" />
            <h2 className="text-xs font-mono text-zinc-500 uppercase tracking-[0.3em]">
              Creative Actions View
            </h2>
            <div className="h-px flex-1 bg-white/5" />
          </div>
          <UiloraActionButtons />
        </section>

        {/* Interactive Playful */}
        <section className="space-y-6">
          <div className="flex items-center gap-4">
            <div className="h-px flex-1 bg-white/5" />
            <h2 className="text-xs font-mono text-zinc-500 uppercase tracking-[0.3em]">
              Interactive Interaction View
            </h2>
            <div className="h-px flex-1 bg-white/5" />
          </div>
          <UiloraInteractiveButtons />
        </section>

        {/* Practical Utility */}
        <section className="space-y-6">
          <div className="flex items-center gap-4">
            <div className="h-px flex-1 bg-white/5" />
            <h2 className="text-xs font-mono text-zinc-500 uppercase tracking-[0.3em]">
              Practical Utility View
            </h2>
            <div className="h-px flex-1 bg-white/5" />
          </div>
          <UiloraUtilityButtons />
        </section>
      </div>
    </div>
  );
}
