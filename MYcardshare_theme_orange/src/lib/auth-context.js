"use client";

import { createContext, useContext, useState, useEffect } from "react";
import { onAuthStateChanged, signOut } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { parseFetchJson } from "@/lib/api";

const AuthContext = createContext({});

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (u) => {
      setUser(u);
      if (u) {
        try {
          const token = await u.getIdToken();
          const res = await fetch("/api/user/me", {
            headers: { Authorization: `Bearer ${token}` },
          });
          const result = await parseFetchJson(res);
          if (result.success) {
            setUserData(result.data);
          } else {
            setUserData(null);
          }
        } catch (err) {
          console.error("Failed to fetch user profile:", err);
          setUserData(null);
        }
      } else {
        setUserData(null);
      }
      setLoading(false);
    });
    return unsub;
  }, []);

  const logout = () => signOut(auth);

  const refreshUserData = async () => {
    if (!user) return;
    try {
      const token = await user.getIdToken();
      const res = await fetch("/api/user/me", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const result = await parseFetchJson(res);
      if (result.success) setUserData(result.data);
      else setUserData(null);
    } catch (err) {
      console.error("Refresh failed:", err);
      setUserData(null);
    }
  };

  return (
    <AuthContext.Provider
      value={{ user, userData, loading, logout, refreshUserData }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
