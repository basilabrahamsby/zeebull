import React, { useState, useEffect, useCallback, useRef } from 'react';
import DashboardLayout from '../layout/DashboardLayout';
import axios from 'axios';
import { getApiBaseUrl } from '../utils/env';

const ActivityLogs = () => {
    const [logs, setLogs] = useState([]);
    const [loading, setLoading] = useState(false);
    const [hasMore, setHasMore] = useState(true);
    const [offset, setOffset] = useState(0);
    const limit = 50;

    const [stats, setStats] = useState(null);
    const [filters, setFilters] = useState({
        method: '',
        path: '',
        status_code: '',
        hours: '24'
    });

    const API_BASE_URL = getApiBaseUrl();

    // Observer for infinite scroll
    const observer = useRef();
    const lastLogElementRef = useCallback(node => {
        if (loading) return;
        if (observer.current) observer.current.disconnect();
        observer.current = new IntersectionObserver(entries => {
            if (entries[0].isIntersecting && hasMore) {
                setOffset(prevOffset => prevOffset + limit);
            }
        });
        if (node) observer.current.observe(node);
    }, [loading, hasMore]);

    // Initial load and filter change
    useEffect(() => {
        setLogs([]);
        setOffset(0);
        setHasMore(true);
        fetchLogs(0, true);
        fetchStats();
    }, [filters]);

    // Load more on scroll (offset change)
    useEffect(() => {
        if (offset > 0) {
            fetchLogs(offset, false);
        }
    }, [offset]);

    const fetchLogs = async (currentOffset, isReset) => {
        if (loading && !isReset) return;

        setLoading(true);
        try {
            const token = localStorage.getItem('token');
            const params = new URLSearchParams();

            if (filters.method) params.append('method', filters.method);
            if (filters.path) params.append('path', filters.path);
            if (filters.status_code) params.append('status_code', filters.status_code);
            if (filters.hours) params.append('hours', filters.hours);

            params.append('limit', limit);
            params.append('skip', currentOffset);

            const response = await axios.get(`${API_BASE_URL}/activity-logs?${params.toString()}`, {
                headers: { Authorization: `Bearer ${token}` }
            });

            const newLogs = response.data.logs || [];

            if (isReset) {
                setLogs(newLogs);
            } else {
                setLogs(prev => [...prev, ...newLogs]);
            }

            setHasMore(newLogs.length === limit);

        } catch (error) {
            console.error('Failed to fetch activity logs:', error);
        } finally {
            setLoading(false);
        }
    };

    const fetchStats = async () => {
        try {
            const token = localStorage.getItem('token');
            const hours = filters.hours || '24';

            const response = await axios.get(`${API_BASE_URL}/activity-logs/stats?hours=${hours}`, {
                headers: { Authorization: `Bearer ${token}` }
            });

            setStats(response.data);
        } catch (error) {
            console.error('Failed to fetch stats:', error);
        }
    };

    const handleFilterChange = (e) => {
        setFilters({
            ...filters,
            [e.target.name]: e.target.value
        });
    };

    const getStatusColor = (statusCode) => {
        if (statusCode >= 200 && statusCode < 300) return 'text-green-600';
        if (statusCode >= 400 && statusCode < 500) return 'text-yellow-600';
        if (statusCode >= 500) return 'text-red-600';
        return 'text-gray-600';
    };

    const getMethodColor = (method) => {
        switch (method) {
            case 'GET': return 'bg-blue-100 text-blue-800';
            case 'POST': return 'bg-green-100 text-green-800';
            case 'PUT': return 'bg-yellow-100 text-yellow-800';
            case 'DELETE': return 'bg-red-100 text-red-800';
            default: return 'bg-gray-100 text-gray-800';
        }
    };

    const formatTimestamp = (timestamp) => {
        if (!timestamp) return 'N/A';
        const date = new Date(timestamp);
        return date.toLocaleString('en-IN', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
    };

    const LogRow = ({ log, isLast, refProp }) => (
        <tr ref={refProp} className="hover:bg-gray-50 border-b border-gray-100">
            <td className="px-4 py-3 text-sm text-gray-900 whitespace-nowrap">{formatTimestamp(log.timestamp)}</td>
            <td className="px-4 py-3 whitespace-nowrap">
                <span className={`px-2 py-1 text-xs font-semibold rounded ${getMethodColor(log.method)}`}>
                    {log.method}
                </span>
            </td>
            <td className="px-4 py-3 text-sm text-gray-900 font-mono break-all max-w-xs">{log.path}</td>
            <td className="px-4 py-3 whitespace-nowrap">
                <span className={`text-sm font-semibold ${getStatusColor(log.status_code)}`}>
                    {log.status_code}
                </span>
            </td>
            <td className="px-4 py-3 text-sm text-gray-600 whitespace-nowrap">{log.client_ip}</td>
            <td className="px-4 py-3 text-sm text-gray-900">
                {log.user_name ? (
                    <div>
                        <div className="font-medium text-xs sm:text-sm">{log.user_name}</div>
                        <div className="text-xs text-gray-500 hidden sm:block">{log.user_email}</div>
                    </div>
                ) : (
                    <span className="text-gray-400 text-xs italic">Guest</span>
                )}
            </td>
            <td className="px-4 py-3 text-sm text-gray-600 max-w-xs truncate" title={log.details}>
                {log.details || "-"}
            </td>
        </tr>
    );

    return (
        <DashboardLayout>
            <div className="p-4 sm:p-6">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 gap-4">
                    <h1 className="text-2xl sm:text-3xl font-bold">Activity Logs</h1>
                    <button
                        onClick={() => { setOffset(0); fetchLogs(0, true); fetchStats(); }}
                        className="px-4 py-2 bg-indigo-50 text-indigo-600 rounded-lg hover:bg-indigo-100 transition-colors text-sm font-medium flex items-center gap-2"
                    >
                        <span>Refresh Logs</span>
                        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                        </svg>
                    </button>
                </div>

                {/* Statistics Cards */}
                {stats && (
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4 mb-6">
                        <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100">
                            <div className="text-xs text-gray-500 uppercase tracking-wide font-semibold">Total Requests</div>
                            <div className="text-2xl font-bold mt-1">{stats.total_requests}</div>
                            <div className="text-xs text-gray-400 mt-1">Last {stats.period_hours} hours</div>
                        </div>
                        <div className="bg-green-50 p-4 rounded-xl shadow-sm border border-green-100">
                            <div className="text-xs text-green-600 uppercase tracking-wide font-semibold">Successful</div>
                            <div className="text-2xl font-bold text-green-700 mt-1">{stats.successful_requests}</div>
                            <div className="text-xs text-green-500 mt-1">{stats.success_rate}% success rate</div>
                        </div>
                        <div className="bg-red-50 p-4 rounded-xl shadow-sm border border-red-100">
                            <div className="text-xs text-red-600 uppercase tracking-wide font-semibold">Errors</div>
                            <div className="text-2xl font-bold text-red-700 mt-1">{stats.error_requests}</div>
                            <div className="text-xs text-red-500 mt-1">{stats.error_rate}% error rate</div>
                        </div>
                        <div className="bg-blue-50 p-4 rounded-xl shadow-sm border border-blue-100">
                            <div className="text-xs text-blue-600 uppercase tracking-wide font-semibold">Showing</div>
                            <div className="text-2xl font-bold text-blue-700 mt-1">{logs.length}</div>
                            <div className="text-xs text-blue-500 mt-1">records loaded</div>
                        </div>
                    </div>
                )}

                {/* Filters */}
                <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 mb-6">
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                        <div>
                            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Method</label>
                            <select
                                name="method"
                                value={filters.method}
                                onChange={handleFilterChange}
                                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all"
                            >
                                <option value="">All Methods</option>
                                <option value="GET">GET</option>
                                <option value="POST">POST</option>
                                <option value="PUT">PUT</option>
                                <option value="DELETE">DELETE</option>
                            </select>
                        </div>
                        <div>
                            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Path</label>
                            <input
                                type="text"
                                name="path"
                                value={filters.path}
                                onChange={handleFilterChange}
                                placeholder="Search path..."
                                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all"
                            />
                        </div>
                        <div>
                            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Status</label>
                            <select
                                name="status_code"
                                value={filters.status_code}
                                onChange={handleFilterChange}
                                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all"
                            >
                                <option value="">All Status</option>
                                <option value="200">200 - OK</option>
                                <option value="400">400 - Bad Request</option>
                                <option value="422">422 - Validation Error</option>
                                <option value="500">500 - Server Error</option>
                            </select>
                        </div>
                        <div>
                            <label className="block text-xs font-semibold text-gray-600 mb-1.5">Period</label>
                            <select
                                name="hours"
                                value={filters.hours}
                                onChange={handleFilterChange}
                                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all"
                            >
                                <option value="1">Last 1 hour</option>
                                <option value="6">Last 6 hours</option>
                                <option value="24">Last 24 hours</option>
                                <option value="168">Last 7 days</option>
                            </select>
                        </div>
                    </div>
                </div>

                {/* Logs Table */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50 border-b border-gray-200">
                                <tr>
                                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Time</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Method</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Path</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Client IP</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">User</th>
                                    <th className="px-4 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Details</th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {logs.map((log, index) => (
                                    <LogRow
                                        key={log.id}
                                        log={log}
                                        isLast={logs.length === index + 1}
                                        refProp={logs.length === index + 1 ? lastLogElementRef : null}
                                    />
                                ))}
                            </tbody>
                        </table>
                        {loading && (
                            <div className="py-8 flex justify-center items-center">
                                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
                            </div>
                        )}
                        {!loading && logs.length === 0 && (
                            <div className="py-12 text-center">
                                <span className="text-4xl block mb-2">🔍</span>
                                <p className="text-gray-500 font-medium">No activity logs found</p>
                                <p className="text-sm text-gray-400 mt-1">Try adjusting your filters</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </DashboardLayout>
    );
};

export default ActivityLogs;
