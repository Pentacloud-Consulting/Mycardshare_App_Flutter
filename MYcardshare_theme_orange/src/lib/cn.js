import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * Merge Tailwind CSS classes with intelligent conflict resolution.
 * Required by all UILORA components.
 */
export function cn(...inputs) {
  return twMerge(clsx(inputs));
}
