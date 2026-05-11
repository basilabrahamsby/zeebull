import React, { useState, useEffect, useCallback } from "react";
import DashboardLayout from "../layout/DashboardLayout";
import API from "../services/api";
import { useBranch } from "../contexts/BranchContext";
import {
  CalendarCheck, CalendarX, Clock, DollarSign, Users, LogIn, LogOut,
  CheckCircle2, AlertTriangle, XCircle, ChevronRight, Loader2,
  TrendingUp, Utensils, Wrench, Banknote, History, RefreshCw, Building2
} from "lucide-react";
import { toast } from "react-hot-toast";

// ─── Helpers ────────────────────────────────────────────────────────────────

function formatDate(d) {
  if (!d) return "—";
  return new Date(d).toLocaleDateString("en-IN", {
    day: "2-digit", month: "short", year: "numeric",
  });
}

function formatTime(ts) {
  if (!ts) return "—";
  return new Date(ts).toLocaleTimeString("en-IN", {
    hour: "2-digit", minute: "2-digit", hour12: true,
  });
}

function formatCurrency(n) {
  return `₹${Number(n || 0).toLocaleString("en-IN", { minimumFractionDigits: 2 })}`;
}

function todayISO() {
  const d = new Date();
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// ─── Sub-components ─────────────────────────────────────────────────────────

function StatCard({ icon, label, value, color = "indigo", sub }) {
  const colors = {
    indigo: "bg-indigo-50 text-indigo-600",
    emerald: "bg-emerald-50 text-emerald-600",
    amber: "bg-amber-50 text-amber-600",
    rose: "bg-rose-50 text-rose-600",
    purple: "bg-purple-50 text-purple-600",
    blue: "bg-blue-50 text-blue-600",
  };
  return (
    <div className="bg-white rounded-2xl border border-gray-100 p-5 flex items-center gap-4 shadow-sm">
      <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${colors[color]}`}>
        {icon}
      </div>
      <div>
        <p className="text-xs text-gray-500 font-medium uppercase tracking-wider">{label}</p>
        <p className="text-2xl font-bold text-gray-800 mt-0.5">{value}</p>
        {sub && <p className="text-xs text-gray-400 mt-0.5">{sub}</p>}
      </div>
    </div>
  );
}

function ChecklistItem({ item }) {
  return (
    <div className={`flex items-center gap-3 p-3 rounded-xl border ${item.ok ? "border-emerald-100 bg-emerald-50" : "border-amber-100 bg-amber-50"}`}>
      {item.ok
        ? <CheckCircle2 className="text-emerald-500 w-5 h-5 flex-shrink-0" />
        : <AlertTriangle className="text-amber-500 w-5 h-5 flex-shrink-0" />}
      <span className="text-sm font-medium text-gray-700 flex-1">{item.label}</span>
      {!item.ok && (
        <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${item.ok ? "bg-emerald-100 text-emerald-700" : "bg-amber-100 text-amber-700"}`}>
          {item.count} pending
        </span>
      )}
      {item.ok && item.count !== undefined && (
        <span className="text-xs font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-700">
          {item.count} in-house
        </span>
      )}
    </div>
  );
}

// ─── Main Page ───────────────────────────────────────────────────────────────

export default function DayAudit() {
  const { activeBranchId, activeBranch } = useBranch();

  const [currentAudit, setCurrentAudit] = useState(null);
  const [history, setHistory] = useState([]);
  const [checklist, setChecklist] = useState(null);
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);

  // Historical Report
  const [selectedAudit, setSelectedAudit] = useState(null);
  const [historicalTransactions, setHistoricalTransactions] = useState([]);
  const [reportLoading, setReportLoading] = useState(false);

  // Open Day form
  const [openForm, setOpenForm] = useState({ 
    business_date: todayISO(), 
    opening_cash_balance: "", 
    opening_account_balance: "",
    opening_notes: "" 
  });
  const [showOpenForm, setShowOpenForm] = useState(false);

  // Close Day form
  const [closeForm, setCloseForm] = useState({ 
    closing_cash_balance: "", 
    closing_account_balance: "",
    system_expected_cash: 0,
    system_expected_account: 0,
    override_reason: "",
    closing_notes: "" 
  });
  const [showCloseConfirm, setShowCloseConfirm] = useState(false);

  // ── Data Fetching ──────────────────────────────────────────────────────────

  const fetchAll = useCallback(async () => {
    setLoading(true);
    try {
      const [currentRes, historyRes] = await Promise.all([
        API.get("/day-audit/current"),
        API.get("/day-audit/history?limit=30"),
      ]);
      const current = currentRes.data;
      setCurrentAudit(current);
      setHistory(historyRes.data || []);

      if (current) {
        const [clRes, txRes] = await Promise.all([
          API.get("/day-audit/checklist"),
          API.get("/day-audit/transactions")
        ]);
        setChecklist(clRes.data);
        const txs = txRes.data || [];
        setTransactions(txs);

        // Calculate expected balances
        let expectedCash = current.opening_cash_balance || 0;
        let expectedAcc = current.opening_account_balance || 0;

        txs.forEach(tx => {
          const type = tx.reference_type?.toLowerCase();
          
          // An expense or payment represents an outflow from cash/bank
          const isOutflow = type === "expense" || type === "purchase_payment" || type === "vendor_payment";
          const amount = tx.total_amount || 0;
          
          const isCash = tx.lines?.some(l => 
            l.debit?.toLowerCase().includes("cash") || 
            l.credit?.toLowerCase().includes("cash")
          );

          const isBank = tx.lines?.some(l => 
            l.debit?.toLowerCase().includes("bank") || 
            l.credit?.toLowerCase().includes("bank")
          );

          // We only track actual cash/bank movements for expected balances
          // Pure accounting entries like 'purchase' (AP) or 'waste' are ignored
          if (isCash) {
            expectedCash += isOutflow ? -amount : amount;
          } else if (isBank) {
            expectedAcc += isOutflow ? -amount : amount;
          }
        });

        setCloseForm(prev => ({
          ...prev,
          closing_cash_balance: expectedCash.toFixed(2),
          closing_account_balance: expectedAcc.toFixed(2),
          system_expected_cash: expectedCash,
          system_expected_account: expectedAcc
        }));

      } else {
        setChecklist(null);
        setTransactions([]);
      }
    } catch (err) {
      console.error("Day audit fetch error:", err);
      toast.error("Failed to load day audit data");
    } finally {
      setLoading(false);
    }
  }, [activeBranchId]);

  useEffect(() => { fetchAll(); }, [fetchAll]);

  // ── Actions ────────────────────────────────────────────────────────────────

  const handleOpenDay = async (e) => {
    e.preventDefault();
    setActionLoading(true);
    try {
      await API.post("/day-audit/open", {
        business_date: openForm.business_date,
        opening_cash_balance: parseFloat(openForm.opening_cash_balance || 0),
        opening_account_balance: parseFloat(openForm.opening_account_balance || 0),
        opening_notes: openForm.opening_notes,
      });
      toast.success("Business day opened successfully!");
      setShowOpenForm(false);
      fetchAll();
    } catch (err) {
      toast.error(err.response?.data?.detail || "Failed to open day");
    } finally {
      setActionLoading(false);
    }
  };

  const handleCloseDay = async (e) => {
    e.preventDefault();
    
    // Validate override reason
    const cashDiff = Math.abs(parseFloat(closeForm.closing_cash_balance || 0) - closeForm.system_expected_cash);
    const accDiff = Math.abs(parseFloat(closeForm.closing_account_balance || 0) - closeForm.system_expected_account);
    
    if ((cashDiff > 0.01 || accDiff > 0.01) && !closeForm.override_reason.trim()) {
      toast.error("Please provide a reason for the balance discrepancy.");
      return;
    }

    setActionLoading(true);
    try {
      await API.post("/day-audit/close", {
        closing_cash_balance: parseFloat(closeForm.closing_cash_balance || 0),
        closing_account_balance: parseFloat(closeForm.closing_account_balance || 0),
        system_expected_cash: closeForm.system_expected_cash,
        system_expected_account: closeForm.system_expected_account,
        override_reason: closeForm.override_reason,
        closing_notes: closeForm.closing_notes,
      });
      toast.success("Day closed & night audit complete!");
      setShowCloseConfirm(false);
      fetchAll();
    } catch (err) {
      toast.error(err.response?.data?.detail || "Night audit failed");
    } finally {
      setActionLoading(false);
    }
  };

  const handleViewReport = async (audit) => {
    setReportLoading(true);
    try {
      const txRes = await API.get(`/day-audit/${audit.id}/transactions`);
      setSelectedAudit(audit);
      setHistoricalTransactions(txRes.data || []);
    } catch (err) {
      toast.error("Failed to load audit transactions");
    } finally {
      setReportLoading(false);
    }
  };

  // ── Helpers ────────────────────────────────────────────────────────────────

  const isCashTransaction = (tx) => {
    return tx.lines?.some(l => 
      l.debit?.toLowerCase().includes("cash") || 
      l.credit?.toLowerCase().includes("cash")
    );
  };

  const isBankTransaction = (tx) => {
    return tx.lines?.some(l => 
      l.debit?.toLowerCase().includes("bank") || 
      l.credit?.toLowerCase().includes("bank")
    );
  };

  const cashTransactions = transactions.filter(isCashTransaction);
  const accountTransactions = transactions.filter(isBankTransaction);

  const splitTransactions = (txs) => {
    const cash = txs.filter(isCashTransaction);
    const acc = txs.filter(isBankTransaction);
    return { cash, acc };
  };

  // ── Render ─────────────────────────────────────────────────────────────────

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-64">
          <Loader2 className="w-8 h-8 text-indigo-500 animate-spin" />
        </div>
      </DashboardLayout>
    );
  }

  const isOpen = currentAudit?.status === "open";

  if (activeBranchId === "all") {
    return (
      <DashboardLayout>
        <div className="max-w-6xl mx-auto flex flex-col items-center justify-center h-[60vh] text-center space-y-4">
          <div className="w-20 h-20 bg-indigo-50 rounded-3xl flex items-center justify-center text-indigo-500">
            <Building2 size={40} />
          </div>
          <h2 className="text-2xl font-bold text-gray-800">Select a Property</h2>
          <p className="text-gray-500 max-w-sm">
            Day Audit operations are property-specific. Please select a specific branch from the sidebar to manage its business day.
          </p>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="max-w-6xl mx-auto space-y-6 pb-10">

        {/* ── Header ── */}
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-800 flex items-center gap-3">
              <CalendarCheck className="text-indigo-600" size={32} />
              Day Audit
            </h1>
            <p className="text-gray-500 mt-1 text-sm">
              Manage the business day lifecycle for{" "}
              <span className="font-semibold text-gray-700">{activeBranch?.name || "this branch"}</span>
            </p>
          </div>
          <button
            onClick={fetchAll}
            className="flex items-center gap-2 px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors"
          >
            <RefreshCw size={15} /> Refresh
          </button>
        </div>

        {/* ── Business Day Status Banner ── */}
        <div className={`rounded-2xl p-6 flex items-center justify-between ${isOpen ? "bg-emerald-500" : "bg-gray-800"}`}>
          <div className="flex items-center gap-4">
            <div className={`w-14 h-14 rounded-2xl flex items-center justify-center ${isOpen ? "bg-emerald-400" : "bg-gray-700"}`}>
              {isOpen ? <CalendarCheck className="text-white" size={28} /> : <CalendarX className="text-gray-300" size={28} />}
            </div>
            <div>
              {isOpen ? (
                <>
                  <p className="text-emerald-100 text-sm font-medium">BUSINESS DAY OPEN</p>
                  <p className="text-white text-2xl font-bold">{formatDate(currentAudit.business_date)}</p>
                  <p className="text-emerald-200 text-sm">Opened at {formatTime(currentAudit.opened_at)}</p>
                </>
              ) : (
                <>
                  <p className="text-gray-400 text-sm font-medium">NO ACTIVE BUSINESS DAY</p>
                  <p className="text-white text-2xl font-bold">Day is Closed</p>
                  <p className="text-gray-400 text-sm">Open a new business day to accept transactions</p>
                </>
              )}
            </div>
          </div>

          <div>
            {isOpen ? (
              <button
                onClick={() => setShowCloseConfirm(true)}
                className="flex items-center gap-2 bg-white text-emerald-700 font-bold px-6 py-3 rounded-xl hover:bg-emerald-50 transition-all shadow-lg"
              >
                <CalendarX size={18} /> Close Day
              </button>
            ) : (
              <button
                onClick={() => setShowOpenForm(true)}
                className="flex items-center gap-2 bg-indigo-600 text-white font-bold px-6 py-3 rounded-xl hover:bg-indigo-500 transition-all shadow-lg"
              >
                <CalendarCheck size={18} /> Open Day
              </button>
            )}
          </div>
        </div>

        {/* ── Live Stats (only when open) ── */}
        {isOpen && currentAudit && (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <StatCard icon={<Users size={22} />} label="In-House Rooms" value={checklist?.checklist?.find(c => c.key === "in_house")?.count ?? "—"} color="indigo" />
            <StatCard icon={<LogIn size={22} />} label="Check-Ins Today" value={currentAudit.new_checkins || 0} color="emerald" />
            <StatCard icon={<LogOut size={22} />} label="Check-Outs Today" value={currentAudit.new_checkouts || 0} color="amber" />
            <StatCard icon={<Banknote size={22} />} label="Payments Received" value={formatCurrency(currentAudit.total_payments_received)} color="blue" />
            <StatCard icon={<Utensils size={22} />} label="Food Revenue" value={formatCurrency(currentAudit.total_food_revenue)} color="rose" />
            <StatCard icon={<Wrench size={22} />} label="Service Revenue" value={formatCurrency(currentAudit.total_service_revenue)} color="purple" />
            <StatCard icon={<DollarSign size={22} />} label="Daily Expenses" value={formatCurrency(currentAudit.total_expenses)} color="rose" />
            <StatCard icon={<History size={22} />} label="Inv. Purchases" value={formatCurrency(currentAudit.total_purchases)} color="amber" />
          </div>
        )}

        {/* ── Cash Transactions ── */}
        {isOpen && (
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-emerald-50/30">
              <h2 className="text-lg font-bold text-gray-800 flex items-center gap-2">
                <Banknote size={20} className="text-emerald-500" />
                Cash Transactions (Today)
              </h2>
              <span className="text-xs text-gray-500 font-medium">{cashTransactions.length} entries</span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-gray-50/50">
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100">Type</th>
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100">Number</th>
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100">Time</th>
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100">Description</th>
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100 text-right">Amount</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {cashTransactions.length === 0 ? (
                    <tr>
                      <td colSpan="5" className="px-6 py-10 text-center text-gray-400 italic">No cash transactions recorded today.</td>
                    </tr>
                  ) : (
                    cashTransactions.map((tx) => (
                      <tr key={tx.id} className="hover:bg-gray-50/30 transition-colors">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className="px-2 py-0.5 rounded-md text-[10px] font-bold uppercase bg-emerald-100 text-emerald-700">
                            {tx.reference_type || "General"}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-600">{tx.entry_number}</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{formatTime(tx.entry_date)}</td>
                        <td className="px-6 py-4 text-sm text-gray-600 max-w-xs truncate" title={tx.description}>{tx.description}</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-800 text-right">{formatCurrency(tx.total_amount)}</td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* ── Account Transactions ── */}
        {isOpen && (
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-indigo-50/30">
              <h2 className="text-lg font-bold text-gray-800 flex items-center gap-2">
                <TrendingUp size={20} className="text-indigo-500" />
                Account/Bank Transactions (Today)
              </h2>
              <span className="text-xs text-gray-500 font-medium">{accountTransactions.length} entries</span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-gray-50/50">
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100">Type</th>
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100">Number</th>
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100">Time</th>
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100">Description</th>
                    <th className="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100 text-right">Amount</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {accountTransactions.length === 0 ? (
                    <tr>
                      <td colSpan="5" className="px-6 py-10 text-center text-gray-400 italic">No bank transactions recorded today.</td>
                    </tr>
                  ) : (
                    accountTransactions.map((tx) => (
                      <tr key={tx.id} className="hover:bg-gray-50/30 transition-colors">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`px-2 py-0.5 rounded-md text-[10px] font-bold uppercase ${
                            tx.reference_type === "CHECKOUT" ? "bg-emerald-100 text-emerald-700" :
                            tx.reference_type === "purchase" ? "bg-amber-100 text-amber-700" :
                            tx.reference_type === "consumption" ? "bg-indigo-100 text-indigo-700" :
                            "bg-gray-100 text-gray-700"
                          }`}>
                            {tx.reference_type || "General"}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-600">{tx.entry_number}</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{formatTime(tx.entry_date)}</td>
                        <td className="px-6 py-4 text-sm text-gray-600 max-w-xs truncate" title={tx.description}>{tx.description}</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-800 text-right">{formatCurrency(tx.total_amount)}</td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* ── Pre-close Checklist (only when open) ── */}
        {isOpen && checklist && (
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
            <h2 className="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
              <CheckCircle2 size={20} className="text-indigo-500" />
              Pre-Close Checklist
            </h2>
            <div className="space-y-2">
              {checklist.checklist.map(item => (
                <ChecklistItem key={item.key} item={item} />
              ))}
            </div>
            {!checklist.can_close && (
              <div className="mt-4 flex items-start gap-3 p-4 bg-amber-50 border border-amber-200 rounded-xl">
                <AlertTriangle className="text-amber-500 flex-shrink-0 mt-0.5" size={18} />
                <p className="text-sm text-amber-800">
                  Resolve all pending items before closing the day. You can still close with warnings by proceeding.
                </p>
              </div>
            )}
          </div>
        )}

        {/* ── Audit History ── */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <h2 className="text-lg font-bold text-gray-800 flex items-center gap-2">
              <History size={20} className="text-indigo-500" />
              Audit History
            </h2>
            <span className="text-xs text-gray-400">Last {history.length} days</span>
          </div>

          {history.length === 0 ? (
            <div className="p-12 text-center text-gray-400">
              <History size={40} className="mx-auto mb-3 opacity-30" />
              <p className="font-medium">No audit history yet</p>
              <p className="text-sm">Open your first business day to begin.</p>
            </div>
          ) : (
            <div className="divide-y divide-gray-50">
              {history.map((audit) => (
                <div key={audit.id} className="px-6 py-4 flex items-center justify-between hover:bg-gray-50/50 transition-colors">
                  <div className="flex items-center gap-4">
                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${audit.status === "closed" ? "bg-gray-100 text-gray-500" : "bg-emerald-100 text-emerald-600"}`}>
                      {audit.status === "closed" ? <CalendarX size={18} /> : <CalendarCheck size={18} />}
                    </div>
                    <div>
                      <p className="font-bold text-gray-800">{formatDate(audit.business_date)}</p>
                      <p className="text-xs text-gray-400">
                        {audit.status === "closed"
                          ? `Closed at ${formatTime(audit.closed_at)}`
                          : `Opened at ${formatTime(audit.opened_at)}`}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-6 text-sm">
                    <div className="text-center hidden md:block">
                      <p className="text-xs text-gray-400">Room Revenue</p>
                      <p className="font-semibold text-gray-700">{formatCurrency(audit.total_room_revenue)}</p>
                    </div>
                    <div className="text-center hidden md:block">
                      <p className="text-xs text-gray-400">Food Revenue</p>
                      <p className="font-semibold text-gray-700">{formatCurrency(audit.total_food_revenue)}</p>
                    </div>
                    <div className="text-center hidden md:block">
                      <p className="text-xs text-gray-400">GST Collected</p>
                      <p className="font-semibold text-indigo-600">{formatCurrency(audit.total_gst_collected)}</p>
                    </div>
                    <div className="text-center">
                      <p className="text-xs text-gray-400">Rooms</p>
                      <p className="font-semibold text-gray-700">{audit.rooms_occupied}</p>
                    </div>
                    <span className={`px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wide ${audit.status === "closed" ? "bg-gray-100 text-gray-500" : "bg-emerald-100 text-emerald-700"}`}>
                      {audit.status}
                    </span>
                    <button
                      onClick={() => handleViewReport(audit)}
                      className="p-2 text-indigo-600 hover:bg-indigo-50 rounded-lg transition-colors"
                      title="View Detailed Report"
                    >
                      <ChevronRight size={20} />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* ── MODAL: Historical Report ── */}
        {selectedAudit && (
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-[60] p-4">
            <div className="bg-slate-50 rounded-3xl shadow-2xl w-full max-w-5xl max-h-[90vh] overflow-hidden flex flex-col">
              {/* Report Header */}
              <div className="bg-white px-8 py-6 border-b border-gray-200 flex items-center justify-between">
                <div>
                  <h3 className="text-2xl font-black text-gray-800 tracking-tight flex items-center gap-3">
                    <History className="text-indigo-600" size={28} />
                    Audit Report: {formatDate(selectedAudit.business_date)}
                    {selectedAudit.status === "open" && (
                      <span className="ml-2 px-2 py-0.5 bg-emerald-500 text-white text-[10px] font-black uppercase rounded-md animate-pulse">
                        LIVE
                      </span>
                    )}
                  </h3>
                  <div className="flex items-center gap-4 mt-1">
                    <span className="text-xs font-bold px-2 py-0.5 bg-gray-100 text-gray-600 rounded uppercase">ID: #{selectedAudit.id}</span>
                    <span className="text-xs text-gray-400">Opened: {formatTime(selectedAudit.opened_at)}</span>
                    <span className="text-xs text-gray-400">Closed: {formatTime(selectedAudit.closed_at)}</span>
                  </div>
                </div>
                <button 
                  onClick={() => setSelectedAudit(null)}
                  className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 hover:bg-gray-200 transition-all"
                >
                  <XCircle size={20} />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-8 space-y-8">
                {/* 1. Summary Grid */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
                    <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4">Revenue Breakdown</p>
                    <div className="space-y-3">
                      <div className="flex justify-between items-center text-sm">
                        <span className="text-gray-500">Room Revenue</span>
                        <span className="font-bold text-gray-800">{formatCurrency(selectedAudit.total_room_revenue)}</span>
                      </div>
                      <div className="flex justify-between items-center text-sm">
                        <span className="text-gray-500">Food Revenue</span>
                        <span className="font-bold text-gray-800">{formatCurrency(selectedAudit.total_food_revenue)}</span>
                      </div>
                      <div className="flex justify-between items-center text-sm">
                        <span className="text-gray-500">Service Revenue</span>
                        <span className="font-bold text-gray-800">{formatCurrency(selectedAudit.total_service_revenue)}</span>
                      </div>
                      <div className="pt-3 border-t border-dashed flex justify-between items-center text-base">
                        <span className="font-bold text-gray-700">Total Revenue</span>
                        <span className="font-black text-indigo-600">{formatCurrency(selectedAudit.total_room_revenue + selectedAudit.total_food_revenue + selectedAudit.total_service_revenue)}</span>
                      </div>
                    </div>
                  </div>

                  <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
                    <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4">Cash Reconciliation</p>
                    <div className="space-y-3">
                      <div className="flex justify-between items-center text-sm">
                        <span className="text-gray-500">Opening Cash</span>
                        <span className="font-bold text-gray-800">{formatCurrency(selectedAudit.opening_cash_balance)}</span>
                      </div>
                      <div className="flex justify-between items-center text-sm">
                        <span className="text-gray-500">Expected Closing</span>
                        <span className="font-bold text-gray-800">{formatCurrency(selectedAudit.system_expected_cash)}</span>
                      </div>
                      <div className="flex justify-between items-center text-sm">
                        <span className="text-gray-500">Actual Closing</span>
                        <span className={`font-bold ${selectedAudit.status === 'open' ? 'text-gray-400 italic' : 'text-emerald-600'}`}>
                          {selectedAudit.status === 'open' ? 'In Progress' : formatCurrency(selectedAudit.closing_cash_balance)}
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
                    <p className="text-[10px] font-black text-indigo-400 uppercase tracking-widest mb-4">Account Reconciliation</p>
                    <div className="space-y-3">
                      <div className="flex justify-between items-center text-sm">
                        <span className="text-gray-500">Opening Account</span>
                        <span className="font-bold text-gray-800">{formatCurrency(selectedAudit.opening_account_balance)}</span>
                      </div>
                      <div className="flex justify-between items-center text-sm">
                        <span className="text-gray-500">Expected Closing</span>
                        <span className="font-bold text-gray-800">{formatCurrency(selectedAudit.system_expected_account)}</span>
                      </div>
                      <div className="flex justify-between items-center text-sm">
                        <span className="text-gray-500">Actual Closing</span>
                        <span className={`font-bold ${selectedAudit.status === 'open' ? 'text-gray-400 italic' : 'text-indigo-600'}`}>
                          {selectedAudit.status === 'open' ? 'In Progress' : formatCurrency(selectedAudit.closing_account_balance)}
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
                    <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4">Other Metrics</p>
                    <div className="space-y-3 text-sm">
                      <div className="flex justify-between items-center">
                        <span className="text-gray-500">GST Collected</span>
                        <span className="font-bold text-indigo-500">{formatCurrency(selectedAudit.total_gst_collected)}</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-gray-500">Inventory Purchases</span>
                        <span className="font-bold text-rose-500">{formatCurrency(selectedAudit.total_purchases)}</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-gray-500">Daily Expenses</span>
                        <span className="font-bold text-rose-500">{formatCurrency(selectedAudit.total_expenses)}</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-gray-500">Rooms Occupied</span>
                        <span className="font-bold text-gray-800">{selectedAudit.rooms_occupied}</span>
                      </div>
                    </div>
                  </div>
                </div>

                {selectedAudit.override_reason && (
                  <div className="p-4 bg-amber-50 rounded-xl text-sm text-amber-800 leading-relaxed border border-amber-100">
                    <strong>Balance Override Reason:</strong> {selectedAudit.override_reason}
                  </div>
                )}

                {/* 2. Transaction Tables */}
                <div className="space-y-6">
                  {/* Cash Table */}
                  <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm">
                    <div className="px-6 py-3 bg-emerald-50 border-b border-gray-100 flex items-center justify-between">
                      <h4 className="text-xs font-black text-emerald-700 uppercase tracking-widest flex items-center gap-2">
                        <Banknote size={14} /> Cash Transaction Log
                      </h4>
                      <span className="text-[10px] font-bold text-emerald-600 bg-white px-2 py-0.5 rounded-full">{splitTransactions(historicalTransactions).cash.length} entries</span>
                    </div>
                    <div className="overflow-x-auto">
                      <table className="w-full text-left text-xs">
                        <thead>
                          <tr className="bg-gray-50/50">
                            <th className="px-6 py-3 font-black text-gray-400 uppercase tracking-widest">Type</th>
                            <th className="px-6 py-3 font-black text-gray-400 uppercase tracking-widest">Time</th>
                            <th className="px-6 py-3 font-black text-gray-400 uppercase tracking-widest">Description</th>
                            <th className="px-6 py-3 font-black text-gray-400 uppercase tracking-widest text-right">Amount</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-50">
                          {splitTransactions(historicalTransactions).cash.map(tx => (
                            <tr key={tx.id} className="hover:bg-gray-50/30">
                              <td className="px-6 py-3 font-bold text-gray-700">{tx.reference_type}</td>
                              <td className="px-6 py-3 text-gray-500 whitespace-nowrap">{formatTime(tx.entry_date)}</td>
                              <td className="px-6 py-3 text-gray-600 truncate max-w-md">{tx.description}</td>
                              <td className="px-6 py-3 text-right font-bold text-gray-800">{formatCurrency(tx.total_amount)}</td>
                            </tr>
                          ))}
                          {splitTransactions(historicalTransactions).cash.length === 0 && (
                            <tr><td colSpan="4" className="px-6 py-8 text-center text-gray-400 italic">No cash transactions this day.</td></tr>
                          )}
                        </tbody>
                      </table>
                    </div>
                  </div>

                  {/* Account Table */}
                  <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm">
                    <div className="px-6 py-3 bg-indigo-50 border-b border-gray-100 flex items-center justify-between">
                      <h4 className="text-xs font-black text-indigo-700 uppercase tracking-widest flex items-center gap-2">
                        <TrendingUp size={14} /> Account/Bank Transaction Log
                      </h4>
                      <span className="text-[10px] font-bold text-indigo-600 bg-white px-2 py-0.5 rounded-full">{splitTransactions(historicalTransactions).acc.length} entries</span>
                    </div>
                    <div className="overflow-x-auto">
                      <table className="w-full text-left text-xs">
                        <thead>
                          <tr className="bg-gray-50/50">
                            <th className="px-6 py-3 font-black text-gray-400 uppercase tracking-widest">Type</th>
                            <th className="px-6 py-3 font-black text-gray-400 uppercase tracking-widest">Time</th>
                            <th className="px-6 py-3 font-black text-gray-400 uppercase tracking-widest">Description</th>
                            <th className="px-6 py-3 font-black text-gray-400 uppercase tracking-widest text-right">Amount</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-50">
                          {splitTransactions(historicalTransactions).acc.map(tx => (
                            <tr key={tx.id} className="hover:bg-gray-50/30">
                              <td className="px-6 py-3 font-bold text-gray-700">{tx.reference_type}</td>
                              <td className="px-6 py-3 text-gray-500 whitespace-nowrap">{formatTime(tx.entry_date)}</td>
                              <td className="px-6 py-3 text-gray-600 truncate max-w-md">{tx.description}</td>
                              <td className="px-6 py-3 text-right font-bold text-gray-800">{formatCurrency(tx.total_amount)}</td>
                            </tr>
                          ))}
                          {splitTransactions(historicalTransactions).acc.length === 0 && (
                            <tr><td colSpan="4" className="px-6 py-8 text-center text-gray-400 italic">No bank transactions this day.</td></tr>
                          )}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </div>

              {/* Modal Footer */}
              <div className="bg-white px-8 py-5 border-t border-gray-200 flex justify-end gap-3">
                <button 
                  onClick={() => window.print()}
                  className="px-6 py-2.5 border border-gray-200 rounded-xl text-gray-600 font-bold hover:bg-gray-50 transition-all flex items-center gap-2"
                >
                  Print Report
                </button>
                <button 
                  onClick={() => setSelectedAudit(null)}
                  className="px-8 py-2.5 bg-indigo-600 text-white font-bold rounded-xl hover:bg-indigo-700 transition-all"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ── MODAL: Open Day ── */}
        {showOpenForm && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md">
              <div className="p-6 border-b border-gray-100 flex items-center justify-between">
                <h3 className="text-xl font-bold text-gray-800 flex items-center gap-2">
                  <CalendarCheck size={22} className="text-emerald-500" />
                  Open Business Day
                </h3>
                <button onClick={() => setShowOpenForm(false)} className="text-gray-400 hover:text-gray-600">
                  <XCircle size={22} />
                </button>
              </div>
              <form onSubmit={handleOpenDay} className="p-6 space-y-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-1.5">Business Date *</label>
                  <input
                    type="date"
                    value={openForm.business_date}
                    onChange={e => setOpenForm({ ...openForm, business_date: e.target.value })}
                    className="w-full border-2 border-gray-100 rounded-xl px-4 py-3 focus:border-indigo-400 outline-none transition-all"
                    required
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1.5">Opening Cash (₹)</label>
                    <input
                      type="number"
                      step="0.01"
                      value={openForm.opening_cash_balance}
                      onChange={e => setOpenForm({ ...openForm, opening_cash_balance: e.target.value })}
                      className="w-full border-2 border-gray-100 rounded-xl px-4 py-3 focus:border-indigo-400 outline-none transition-all"
                      placeholder="0.00"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1.5">Opening Account (₹)</label>
                    <input
                      type="number"
                      step="0.01"
                      value={openForm.opening_account_balance}
                      onChange={e => setOpenForm({ ...openForm, opening_account_balance: e.target.value })}
                      className="w-full border-2 border-gray-100 rounded-xl px-4 py-3 focus:border-indigo-400 outline-none transition-all"
                      placeholder="0.00"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-1.5">Opening Notes</label>
                  <textarea
                    value={openForm.opening_notes}
                    onChange={e => setOpenForm({ ...openForm, opening_notes: e.target.value })}
                    className="w-full border-2 border-gray-100 rounded-xl px-4 py-3 focus:border-indigo-400 outline-none transition-all"
                    rows={2}
                    placeholder="Any notes for this business day..."
                  />
                </div>
                <div className="flex gap-3 pt-2">
                  <button type="button" onClick={() => setShowOpenForm(false)}
                    className="flex-1 py-3 border-2 border-gray-100 rounded-xl text-gray-600 font-semibold hover:bg-gray-50 transition-all">
                    Cancel
                  </button>
                  <button type="submit" disabled={actionLoading}
                    className="flex-1 py-3 bg-emerald-500 text-white font-bold rounded-xl hover:bg-emerald-600 transition-all flex items-center justify-center gap-2 disabled:opacity-60">
                    {actionLoading ? <Loader2 size={18} className="animate-spin" /> : <CalendarCheck size={18} />}
                    Open Day
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* ── MODAL: Close Day ── */}
        {showCloseConfirm && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md">
              <div className="p-6 border-b border-gray-100 flex items-center justify-between">
                <h3 className="text-xl font-bold text-gray-800 flex items-center gap-2">
                  <CalendarX size={22} className="text-rose-500" />
                  Close Business Day
                </h3>
                <button onClick={() => setShowCloseConfirm(false)} className="text-gray-400 hover:text-gray-600">
                  <XCircle size={22} />
                </button>
              </div>

              {/* Checklist summary in modal */}
              {checklist && (
                <div className="px-6 pt-4 space-y-2">
                  {checklist.checklist.map(item => (
                    <ChecklistItem key={item.key} item={item} />
                  ))}
                </div>
              )}

              <form onSubmit={handleCloseDay} className="p-6 space-y-4">
                <div className="p-4 bg-rose-50 border border-rose-100 rounded-xl text-xs text-rose-800 leading-relaxed">
                  <strong>Night Audit will run automatically:</strong> Room charges with GST will be posted to all in-house guests.
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-1">
                    <label className="block text-[11px] font-black text-gray-400 uppercase tracking-widest">Closing Cash (₹)</label>
                    <input
                      type="number"
                      step="0.01"
                      value={closeForm.closing_cash_balance}
                      onChange={e => setCloseForm({ ...closeForm, closing_cash_balance: e.target.value })}
                      className={`w-full border-2 rounded-xl px-4 py-3 focus:ring-4 transition-all outline-none font-bold ${
                        Math.abs(parseFloat(closeForm.closing_cash_balance || 0) - closeForm.system_expected_cash) > 0.01
                        ? "border-amber-200 bg-amber-50 focus:border-amber-400 focus:ring-amber-100"
                        : "border-gray-100 focus:border-indigo-400 focus:ring-indigo-100"
                      }`}
                    />
                    <p className="text-[10px] text-gray-400 font-medium">System expects: <span className="text-gray-600 font-bold">{formatCurrency(closeForm.system_expected_cash)}</span></p>
                  </div>
                  <div className="space-y-1">
                    <label className="block text-[11px] font-black text-gray-400 uppercase tracking-widest">Closing Account (₹)</label>
                    <input
                      type="number"
                      step="0.01"
                      value={closeForm.closing_account_balance}
                      onChange={e => setCloseForm({ ...closeForm, closing_account_balance: e.target.value })}
                      className={`w-full border-2 rounded-xl px-4 py-3 focus:ring-4 transition-all outline-none font-bold ${
                        Math.abs(parseFloat(closeForm.closing_account_balance || 0) - closeForm.system_expected_account) > 0.01
                        ? "border-amber-200 bg-amber-50 focus:border-amber-400 focus:ring-amber-100"
                        : "border-gray-100 focus:border-indigo-400 focus:ring-indigo-100"
                      }`}
                    />
                    <p className="text-[10px] text-gray-400 font-medium">System expects: <span className="text-gray-600 font-bold">{formatCurrency(closeForm.system_expected_account)}</span></p>
                  </div>
                </div>

                {(Math.abs(parseFloat(closeForm.closing_cash_balance || 0) - closeForm.system_expected_cash) > 0.01 || 
                  Math.abs(parseFloat(closeForm.closing_account_balance || 0) - closeForm.system_expected_account) > 0.01) && (
                  <div className="animate-in fade-in slide-in-from-top-2 duration-300">
                    <label className="block text-[11px] font-black text-amber-600 uppercase tracking-widest mb-1.5 flex items-center gap-1.5">
                      <AlertTriangle size={12} />
                      Override Reason (Required)
                    </label>
                    <textarea
                      value={closeForm.override_reason}
                      onChange={e => setCloseForm({ ...closeForm, override_reason: e.target.value })}
                      className="w-full border-2 border-amber-200 bg-amber-50/50 rounded-xl px-4 py-3 focus:border-amber-400 focus:ring-4 focus:ring-amber-100 outline-none transition-all text-sm"
                      rows={2}
                      placeholder="Explain the reason for the balance discrepancy..."
                      required
                    />
                  </div>
                )}

                <div>
                  <label className="block text-[11px] font-black text-gray-400 uppercase tracking-widest mb-1.5">Closing Notes</label>
                  <textarea
                    value={closeForm.closing_notes}
                    onChange={e => setCloseForm({ ...closeForm, closing_notes: e.target.value })}
                    className="w-full border-2 border-gray-100 rounded-xl px-4 py-3 focus:border-indigo-400 outline-none transition-all text-sm"
                    rows={2}
                    placeholder="End of day summary..."
                  />
                </div>
                <div className="flex gap-3 pt-2">
                  <button type="button" onClick={() => setShowCloseConfirm(false)}
                    className="flex-1 py-3 border-2 border-gray-100 rounded-xl text-gray-600 font-semibold hover:bg-gray-50 transition-all">
                    Cancel
                  </button>
                  <button type="submit" disabled={actionLoading}
                    className="flex-1 py-3 bg-rose-500 text-white font-bold rounded-xl hover:bg-rose-600 transition-all flex items-center justify-center gap-2 disabled:opacity-60 shadow-lg shadow-rose-200">
                    {actionLoading ? <Loader2 size={18} className="animate-spin" /> : <CalendarX size={18} />}
                    Close & Run Audit
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

      </div>
    </DashboardLayout>
  );
}
