import React, { useState, useEffect } from "react";
import { Lock, ShieldAlert, KeyRound, Copy, Check, Phone, Mail, MessageSquare, AlertCircle, ArrowRight, RefreshCw } from "lucide-react";
import axios from "axios";
import { getApiBaseUrl } from "../utils/env";
import { toast } from "react-hot-toast";

export default function SuspendedLockScreen({ initialLockData = null, onUnlocked = null }) {
  const [lockData, setLockData] = useState(initialLockData);
  const [activationKey, setActivationKey] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [copied, setCopied] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  const apiBaseUrl = getApiBaseUrl();

  const fetchLockStatus = async () => {
    try {
      const res = await axios.get(`${apiBaseUrl}/api/system-lock/status`);
      setLockData(res.data);
      if (!res.data.is_locked && onUnlocked) {
        onUnlocked();
      }
    } catch (err) {
      console.error("Failed to fetch lock status:", err);
    }
  };

  useEffect(() => {
    if (!lockData || !lockData.reference_code) {
      fetchLockStatus();
    }
    // Poll every 15 seconds in case server is unlocked remotely via SSH CLI
    const interval = setInterval(fetchLockStatus, 15000);
    return () => clearInterval(interval);
  }, []);

  const handleCopyRef = () => {
    if (!lockData?.reference_code) return;
    navigator.clipboard.writeText(lockData.reference_code);
    setCopied(true);
    toast.success("Lock Reference Code copied to clipboard!");
    setTimeout(() => setCopied(false), 2500);
  };

  const handleKeyChange = (e) => {
    let val = e.target.value.toUpperCase();
    // Allow uppercase alphanumeric and hyphens
    val = val.replace(/[^A-Z0-9-]/g, "");
    setActivationKey(val);
    setErrorMsg("");
  };

  const handleUnlock = async (e) => {
    e.preventDefault();
    if (!activationKey.trim()) {
      setErrorMsg("Please enter the unique activation key.");
      return;
    }

    setIsLoading(true);
    setErrorMsg("");
    setSuccessMsg("");

    try {
      const res = await axios.post(`${apiBaseUrl}/api/system-lock/unlock`, {
        activation_key: activationKey.trim()
      });

      if (res.data?.success) {
        setSuccessMsg(res.data.message || "System successfully unlocked!");
        toast.success("Service Restored! Refreshing dashboard...", { duration: 3000 });
        setTimeout(() => {
          if (onUnlocked) {
            onUnlocked();
          } else {
            window.location.reload();
          }
        }, 1500);
      }
    } catch (err) {
      const detail = err.response?.data?.detail || "Invalid or expired activation key. Please contact support.";
      setErrorMsg(detail);
      toast.error(detail);
    } finally {
      setIsLoading(false);
    }
  };

  const refCode = lockData?.reference_code || "ZEB-SUSPENDED";
  const reason = lockData?.reason || "Administrative services suspended due to pending account settlement.";
  const phone = lockData?.support_phone || "+91 94000 00000";
  const email = lockData?.support_email || "billing@teqmates.com";
  const waMsg = encodeURIComponent(
    `Hello TeqMates Billing Team,\n\nOur dashboard is currently suspended with Reference Code: ${refCode}.\nWe would like to settle the outstanding account and request an activation key to restore service.\n\nThank you.`
  );
  const waUrl = `https://wa.me/?text=${waMsg}`;

  return (
    <div className="fixed inset-0 z-[99999] flex items-center justify-center bg-slate-950/95 backdrop-blur-md p-4 sm:p-6 overflow-y-auto">
      <div className="w-full max-w-xl bg-slate-900 border border-red-500/30 rounded-2xl shadow-2xl shadow-red-950/50 p-6 sm:p-8 relative overflow-hidden">
        {/* Decorative ambient gradient */}
        <div className="absolute -top-24 -left-24 w-60 h-60 bg-red-600/15 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-24 -right-24 w-60 h-60 bg-amber-600/10 rounded-full blur-3xl pointer-events-none" />

        {/* Header Badge & Icon */}
        <div className="flex flex-col items-center text-center relative z-10">
          <div className="w-16 h-16 rounded-2xl bg-red-500/10 border border-red-500/30 flex items-center justify-center text-red-400 mb-4 shadow-inner">
            <Lock className="w-8 h-8 animate-pulse" />
          </div>

          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-red-500/10 border border-red-500/20 text-red-400 text-xs font-semibold uppercase tracking-wider mb-2">
            <ShieldAlert className="w-3.5 h-3.5" />
            <span>Service Suspended</span>
          </div>

          <h2 className="text-2xl sm:text-3xl font-bold text-white tracking-tight">
            Administrative Access Locked
          </h2>
          <p className="text-sm sm:text-base text-slate-300 mt-2 max-w-md">
            {reason}
          </p>
        </div>

        {/* Lock Reference Code Box */}
        <div className="mt-6 bg-slate-950/80 border border-slate-800 rounded-xl p-4 relative z-10">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-400 uppercase tracking-wider">
              System Lock Reference Code
            </span>
            <button
              onClick={handleCopyRef}
              className="inline-flex items-center gap-1 text-xs font-medium text-amber-400 hover:text-amber-300 transition-colors"
            >
              {copied ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
              <span>{copied ? "Copied" : "Copy Code"}</span>
            </button>
          </div>
          <div className="mt-2 flex items-center justify-between">
            <span className="font-mono text-xl sm:text-2xl font-bold text-amber-300 tracking-wider">
              {refCode}
            </span>
            <span className="text-[11px] bg-slate-800 text-slate-400 px-2 py-0.5 rounded">
              Quote this to Billing
            </span>
          </div>
        </div>

        {/* Activation Form */}
        <form onSubmit={handleUnlock} className="mt-6 relative z-10 space-y-4">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-300 mb-2">
              Enter Unique Activation Key
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-500">
                <KeyRound className="w-5 h-5" />
              </div>
              <input
                type="text"
                value={activationKey}
                onChange={handleKeyChange}
                placeholder="ACT-XXXX-XXXX-XXXX-XXXX"
                disabled={isLoading}
                className="w-full pl-11 pr-4 py-3 bg-slate-950 border border-slate-700 rounded-xl font-mono text-sm sm:text-base text-white tracking-widest placeholder-slate-600 focus:outline-none focus:border-amber-400 focus:ring-2 focus:ring-amber-400/20 transition-all uppercase"
              />
            </div>
          </div>

          {errorMsg && (
            <div className="flex items-start gap-2 p-3 bg-red-500/10 border border-red-500/30 rounded-xl text-red-400 text-xs sm:text-sm">
              <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
              <span>{errorMsg}</span>
            </div>
          )}

          {successMsg && (
            <div className="flex items-start gap-2 p-3 bg-emerald-500/10 border border-emerald-500/30 rounded-xl text-emerald-400 text-xs sm:text-sm">
              <Check className="w-4 h-4 mt-0.5 flex-shrink-0" />
              <span>{successMsg}</span>
            </div>
          )}

          <button
            type="submit"
            disabled={isLoading || !activationKey.trim()}
            className="w-full py-3.5 px-4 bg-gradient-to-r from-red-600 to-amber-600 hover:from-red-500 hover:to-amber-500 active:scale-[0.99] disabled:opacity-50 disabled:cursor-not-allowed text-white font-semibold rounded-xl shadow-lg shadow-red-900/30 flex items-center justify-center gap-2 transition-all"
          >
            {isLoading ? (
              <>
                <RefreshCw className="w-4 h-4 animate-spin" />
                <span>Verifying Activation Key...</span>
              </>
            ) : (
              <>
                <span>Unlock & Restore Service</span>
                <ArrowRight className="w-4 h-4" />
              </>
            )}
          </button>
        </form>

        {/* Support & Contact Quick Actions */}
        <div className="mt-6 pt-5 border-t border-slate-800 relative z-10">
          <div className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3 text-center">
            Need an Activation Key? Contact Billing
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
            <a
              href={waUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center justify-center gap-2 py-2.5 px-3 bg-emerald-950/60 hover:bg-emerald-900/60 border border-emerald-700/40 text-emerald-300 rounded-lg text-xs font-medium transition-colors"
            >
              <MessageSquare className="w-4 h-4" />
              <span>WhatsApp Support</span>
            </a>
            <a
              href={`mailto:${email}?subject=Activation%20Key%20Request%20-%20${refCode}`}
              className="flex items-center justify-center gap-2 py-2.5 px-3 bg-slate-800/80 hover:bg-slate-700/80 border border-slate-700 text-slate-200 rounded-lg text-xs font-medium transition-colors"
            >
              <Mail className="w-4 h-4" />
              <span>{email}</span>
            </a>
          </div>
          {phone && (
            <div className="mt-3 flex items-center justify-center gap-1.5 text-xs text-slate-400">
              <Phone className="w-3.5 h-3.5 text-slate-500" />
              <span>Hotline: <strong className="text-slate-300">{phone}</strong></span>
            </div>
          )}
        </div>

        {/* Guest portal notice */}
        <div className="mt-5 text-center text-[11px] text-slate-500 relative z-10">
          Note: Public guest website and reservations remain active. Only admin portal access is suspended.
        </div>
      </div>
    </div>
  );
}
