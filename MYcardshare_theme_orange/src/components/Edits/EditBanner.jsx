"use client";

import { useState, useCallback } from "react";
import Cropper from "react-easy-crop";
import { X, Check, ZoomIn } from "lucide-react";
import { authFetch, parseFetchJson } from "@/lib/api";

/**
 * Helper to create a cropped image file from the crop area pixels
 */
async function getCroppedImg(imageSrc, pixelCrop) {
  const image = await new Promise((resolve, reject) => {
    const img = new window.Image();
    img.addEventListener("load", () => resolve(img));
    img.addEventListener("error", (error) => reject(error));
    img.setAttribute("crossOrigin", "anonymous");
    img.src = imageSrc;
  });

  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d");

  canvas.width = pixelCrop.width;
  canvas.height = pixelCrop.height;

  ctx.drawImage(
    image,
    pixelCrop.x,
    pixelCrop.y,
    pixelCrop.width,
    pixelCrop.height,
    0,
    0,
    pixelCrop.width,
    pixelCrop.height
  );

  return new Promise((resolve) => {
    canvas.toBlob((blob) => {
      resolve(blob);
    }, "image/jpeg");
  });
}

export default function EditBanner({ imageUrl, onSave, onClose }) {
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState(null);
  const [loading, setLoading] = useState(false);

  const onCropComplete = useCallback((_croppedArea, _croppedAreaPixels) => {
    setCroppedAreaPixels(_croppedAreaPixels);
  }, []);

  const handleSave = async () => {
    if (!croppedAreaPixels) return;
    setLoading(true);
    try {
      const croppedBlob = await getCroppedImg(imageUrl, croppedAreaPixels);
      const file = new File([croppedBlob], "banner_crop.jpg", { type: "image/jpeg" });

      const fd = new FormData();
      fd.append("type", "banner");
      fd.append("file", file);

      const res = await authFetch("/api/user/upload", {
        method: "POST",
        body: fd,
      });
      const data = await parseFetchJson(res);

      if (data.success && data.data?.url) {
        onSave(data.data.url);
        onClose();
      } else {
        alert("Failed to save cropped image.");
      }
    } catch (err) {
      console.error(err);
      alert("Error processing image.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-black/40 backdrop-blur-sm">
      <div className="w-full max-w-4xl bg-white border border-[#EFE8E1] rounded-[2.5rem] overflow-hidden shadow-2xl flex flex-col h-[80vh]">
        {/* Header */}
        <div className="p-6 border-b border-[#EFE8E1] flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-[#FAF6F2] border border-[#EFE8E1] flex items-center justify-center text-[#D4642C]">
              <ZoomIn size={20} />
            </div>
            <div>
              <h3 className="text-lg font-black text-[#18181B] tracking-tight">Resize Banner</h3>
              <p className="text-xs text-[#78716C] font-bold uppercase tracking-widest">Crop to 3:1 aspect ratio</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-xl bg-[#FAF6F2] text-[#78716C] hover:text-[#18181B] transition-all cursor-pointer"
          >
            <X size={20} />
          </button>
        </div>

        {/* Cropper Container */}
        <div className="flex-1 relative bg-black/10">
          <Cropper
            image={imageUrl}
            crop={crop}
            zoom={zoom}
            aspect={3 / 1}
            onCropChange={setCrop}
            onCropComplete={onCropComplete}
            onZoomChange={setZoom}
            classes={{
              containerClassName: "bg-black/10",
              mediaClassName: "max-h-full",
            }}
          />
        </div>

        {/* Controls */}
        <div className="p-8 bg-[#FAF6F2] border-t border-[#EFE8E1] space-y-6">
          <div className="flex items-center gap-6">
            <ZoomIn size={18} className="text-[#78716C]" />
            <input
              type="range"
              value={zoom}
              min={1}
              max={3}
              step={0.1}
              aria-labelledby="Zoom"
              onChange={(e) => setZoom(Number(e.target.value))}
              className="flex-1 h-1 bg-[#EFE8E1] rounded-lg appearance-none cursor-pointer accent-[#D4642C]"
            />
          </div>

          <div className="flex gap-4">
            <button
              onClick={onClose}
              className="flex-1 py-4 rounded-full bg-white border border-[#EFE8E1] text-[#57534E] font-black text-xs uppercase tracking-widest hover:bg-[#FAF6F2] transition-all cursor-pointer"
            >
              Cancel
            </button>
            <button
              onClick={handleSave}
              disabled={loading}
              className="flex-[2] py-4 rounded-full bg-[#D4642C] text-white font-black text-xs uppercase tracking-widest hover:bg-[#B85323] transition-all shadow-[0_8px_20px_rgba(212,100,44,0.25)] flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50"
            >
              {loading ? (
                "Saving..."
              ) : (
                <>
                  <Check size={18} /> Save & Upload
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
