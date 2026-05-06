import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../services/api";
import zeebullLogo from "../assets/zeebulllogo.png";
import { jwtDecode } from "jwt-decode";
import { Mail, Lock, ArrowRight, Loader2, Sparkles, Building2, ShieldCheck } from "lucide-react";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const response = await api.post("/auth/login", { email, password });
      if (response.data && response.data.access_token) {
        localStorage.setItem("token", response.data.access_token);

        try {
          const settingsRes = await api.get("settings/");
          const tzSetting = settingsRes.data.find(s => s.key === "timezone");
          if (tzSetting && tzSetting.value) {
            localStorage.setItem("SYSTEM_TIMEZONE", tzSetting.value);
          }
        } catch (settingsError) {
          console.error("Failed to sync system timezone on login:", settingsError);
        }

        try {
          const decoded = jwtDecode(response.data.access_token);
          const permissions = decoded.permissions || [];
          const role = decoded.role ? decoded.role.toLowerCase() : 'guest';
          const isSuperadmin = decoded.is_superadmin || false;
          const userBranchId = decoded.branch_id;

          localStorage.setItem("user", JSON.stringify({
            role,
            is_superadmin: isSuperadmin,
            permissions
          }));
          localStorage.setItem("permissions", JSON.stringify(permissions));

          if (isSuperadmin) {
            localStorage.setItem("activeBranchId", "all");
            navigate("/superadmin-dashboard", { replace: true });
          } else if (userBranchId) {
            localStorage.setItem("activeBranchId", userBranchId);
            
            if (role === 'admin' || permissions.some(p => p === '/dashboard' || p === 'dashboard:view' || p === 'dashboard')) {
              navigate("/dashboard", { replace: true });
            } else if (permissions.length > 0) {
              const firstPerm = permissions[0];
              const redirectPath = firstPerm.startsWith('/') 
                ? firstPerm 
                : `/${firstPerm.split(':')[0].replace('_', '-')}`;
              navigate(redirectPath, { replace: true });
            } else {
              navigate("/dashboard", { replace: true });
            }
          }
        } catch (error) {
          console.error("Token decode error:", error);
          navigate("/dashboard", { replace: true });
        }
      } else {
        alert("Login failed: No token received from server.");
      }
    } catch (err) {
      console.error("Login error:", err);
      const errorMessage = err.response?.data?.detail || err.message || "Login failed. Please check your credentials.";
      alert(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-full flex bg-[#0f172a] font-sans overflow-hidden">
      
      {/* LEFT PANEL - Form Area */}
      <div className="w-full lg:w-[45%] xl:w-[35%] flex flex-col justify-between bg-white relative z-10 shadow-2xl">
        
        {/* Subtle top decoration */}
        <div className="absolute top-0 left-0 w-full h-1.5 bg-gradient-to-r from-[#2d5016] via-[#8bc34a] to-[#c5e1a5]"></div>

        <div className="flex-1 flex flex-col justify-center px-8 sm:px-12 md:px-16 lg:px-20 py-12">
          
          {/* Logo Section */}
          <div className="mb-10 text-center flex flex-col items-center">
            <div className="relative group mb-6">
              <div className="absolute -inset-2 bg-gradient-to-r from-[#8bc34a] to-[#2d5016] rounded-[2rem] blur opacity-20 group-hover:opacity-40 transition duration-700"></div>
              {/* Enhanced Logo Container */}
              <div className="relative bg-[#1b3d1b] rounded-3xl p-3 shadow-xl transform transition-transform duration-500 group-hover:scale-105 border border-white/10 ring-4 ring-black/5 overflow-hidden">
                <img
                  src={zeebullLogo}
                  alt="Zeebull Hospitality Logo"
                  className="h-28 w-auto object-contain mix-blend-screen opacity-95"
                  style={{ filter: 'contrast(1.2) brightness(1.1)' }}
                />
              </div>
            </div>
            
            <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">
              Welcome Back
            </h1>
            <p className="text-gray-500 mt-2 font-medium">
              Enter your credentials to access the portal
            </p>
          </div>

          {/* Form Section */}
          <form onSubmit={handleLogin} className="space-y-6">
            <div className="space-y-1">
              <label className="text-sm font-semibold text-gray-700 block ml-1">Email / Username</label>
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400 group-focus-within:text-[#689f38] transition-colors">
                  <Mail size={20} />
                </div>
                <input
                  type="text"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="block w-full pl-11 pr-4 py-3.5 bg-gray-50 border border-gray-200 rounded-xl text-gray-900 placeholder-gray-400 focus:bg-white focus:ring-2 focus:ring-[#8bc34a]/30 focus:border-[#8bc34a] transition-all outline-none"
                  placeholder="name@zeebull.com"
                  required
                />
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex items-center justify-between ml-1">
                <label className="text-sm font-semibold text-gray-700 block">Password</label>
                <a href="#" className="text-xs font-semibold text-[#689f38] hover:text-[#2d5016] transition-colors">Forgot password?</a>
              </div>
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400 group-focus-within:text-[#689f38] transition-colors">
                  <Lock size={20} />
                </div>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full pl-11 pr-4 py-3.5 bg-gray-50 border border-gray-200 rounded-xl text-gray-900 placeholder-gray-400 focus:bg-white focus:ring-2 focus:ring-[#8bc34a]/30 focus:border-[#8bc34a] transition-all outline-none"
                  placeholder="••••••••"
                  required
                />
              </div>
            </div>

            <div className="flex items-center ml-1">
              <input
                id="remember-me"
                type="checkbox"
                checked={rememberMe}
                onChange={() => setRememberMe(!rememberMe)}
                className="h-4 w-4 text-[#689f38] focus:ring-[#8bc34a] border-gray-300 rounded cursor-pointer transition-colors"
              />
              <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-600 cursor-pointer select-none">
                Remember me
              </label>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full flex items-center justify-center gap-2 py-3.5 px-4 bg-gradient-to-r from-[#558b2f] to-[#7cb342] hover:from-[#33691e] hover:to-[#558b2f] text-white font-bold rounded-xl shadow-lg shadow-[#8bc34a]/30 transform transition-all active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed group"
            >
              {loading ? (
                <>
                  <Loader2 className="animate-spin" size={20} />
                  <span>Authenticating...</span>
                </>
              ) : (
                <>
                  <span>Sign In to Dashboard</span>
                  <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
                </>
              )}
            </button>
          </form>

        </div>

        {/* Footer */}
        <div className="px-8 py-6 bg-gray-50/50 border-t border-gray-100 flex items-center justify-between text-xs text-gray-400">
          <span>© {new Date().getFullYear()} Zeebull Group</span>
          <div className="flex items-center gap-1.5 font-medium text-gray-500">
            <ShieldCheck size={14} className="text-emerald-500" />
            Secure Login
          </div>
        </div>
      </div>

      {/* RIGHT PANEL - Brand Image Area */}
      <div className="hidden lg:flex flex-1 relative bg-[#1b3d1b]">
        {/* Generated Resort Background */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat transition-transform duration-[20s] hover:scale-105 ease-in-out"
          style={{ backgroundImage: "url('/login-bg.png')" }}
        />
        
        {/* Gradient Overlay for text readability */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-black/10"></div>
        <div className="absolute inset-0 bg-gradient-to-r from-[#1b3d1b]/60 to-transparent"></div>

        {/* Content over image */}
        <div className="relative z-10 flex flex-col justify-end p-16 w-full h-full text-white">
          <div className="max-w-xl">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/10 backdrop-blur-md border border-white/20 text-sm font-medium mb-6">
              <Sparkles size={16} className="text-[#c5e1a5]" />
              <span className="text-[#e8f5e9]">Premium Property Management</span>
            </div>
            
            <h2 className="text-5xl font-bold leading-tight mb-6 text-transparent bg-clip-text bg-gradient-to-r from-white to-[#e8f5e9]">
              Elevate Your <br /> Guest Experience
            </h2>
            
            <p className="text-lg text-gray-300 leading-relaxed font-light border-l-2 border-[#8bc34a] pl-4">
              A comprehensive, intelligent platform designed to streamline operations, maximize revenue, and deliver unforgettable stays.
            </p>

            <div className="flex items-center gap-8 mt-12 pt-12 border-t border-white/10">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-xl bg-white/10 backdrop-blur-md flex items-center justify-center border border-white/10">
                  <Building2 size={24} className="text-[#8bc34a]" />
                </div>
                <div>
                  <p className="text-xl font-bold text-white">Multi-Property</p>
                  <p className="text-xs text-gray-400">Centralized control</p>
                </div>
              </div>
              <div className="w-px h-10 bg-white/10"></div>
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-xl bg-white/10 backdrop-blur-md flex items-center justify-center border border-white/10">
                  <ShieldCheck size={24} className="text-[#8bc34a]" />
                </div>
                <div>
                  <p className="text-xl font-bold text-white">Enterprise Grade</p>
                  <p className="text-xs text-gray-400">Secure & Reliable</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
