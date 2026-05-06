import React, { useState, useMemo } from 'react';
import { motion } from 'framer-motion';
import { 
  ChevronLeft, 
  ChevronRight, 
  Calendar as CalendarIcon, 
  User, 
  Clock, 
  Info,
  Globe
} from 'lucide-react';

const BookingCalendar = ({ rooms, bookings, roomTypeObjects }) => {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [viewDays, setViewDays] = useState(14); // Number of days to show

  // Generate date range
  const dateRange = useMemo(() => {
    const dates = [];
    const start = new Date(currentDate);
    start.setHours(0, 0, 0, 0);
    
    for (let i = 0; i < viewDays; i++) {
      const d = new Date(start);
      d.setDate(start.getDate() + i);
      dates.push(d);
    }
    return dates;
  }, [currentDate, viewDays]);

  const formatDate = (date) => {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  };

  const getDayName = (date) => {
    return date.toLocaleDateString('en-US', { weekday: 'short' });
  };

  const isToday = (date) => {
    const today = new Date();
    return formatDate(date) === formatDate(today);
  };

  // Group rooms by type
  const roomTypeGroups = useMemo(() => {
    const groups = {};
    rooms.forEach(room => {
      const typeName = room.type || 'Uncategorized';
      if (!groups[typeName]) {
        groups[typeName] = {
          name: typeName,
          rooms: [],
          totalRooms: 0,
          bookings: []
        };
      }
      groups[typeName].rooms.push(room);
      groups[typeName].totalRooms++;
    });

    // Add bookings to their respective groups
    (bookings || []).forEach(booking => {
      if (booking.status === 'cancelled') return;
      
      const processedRooms = new Set();
      (booking.rooms || []).forEach(r => {
        const roomId = r.room?.id || r.id;
        const room = rooms.find(rm => rm.id === roomId);
        if (room) {
          const typeName = room.type || 'Uncategorized';
          if (groups[typeName] && !processedRooms.has(typeName)) {
             // For simplicity, we show the booking once per room type it occupies
             // Usually a booking is for one room type anyway
             groups[typeName].bookings.push(booking);
             processedRooms.add(typeName);
          }
        }
      });
      
      // If booking has room_type_id but no physical rooms yet (soft allocation)
      if (booking.room_type_id && (!booking.rooms || booking.rooms.length === 0)) {
        const roomType = roomTypeObjects.find(rt => rt.id === booking.room_type_id);
        if (roomType && groups[roomType.name]) {
          groups[roomType.name].bookings.push(booking);
        }
      }
    });

    return Object.values(groups).sort((a, b) => a.name.localeCompare(b.name));
  }, [rooms, bookings, roomTypeObjects]);

  // Helper to calculate occupancy for a type on a specific date
  const getOccupancyOnDate = (group, date) => {
    const dStr = formatDate(date);
    return group.bookings.filter(b => {
      return b.check_in <= dStr && b.check_out > dStr;
    }).length;
  };

  const nextRange = () => {
    const next = new Date(currentDate);
    next.setDate(currentDate.getDate() + viewDays);
    setCurrentDate(next);
  };

  const prevRange = () => {
    const prev = new Date(currentDate);
    prev.setDate(currentDate.getDate() - viewDays);
    setCurrentDate(prev);
  };

  const goToToday = () => {
    setCurrentDate(new Date());
  };

  return (
    <div className="bg-white rounded-3xl shadow-xl border border-gray-100 overflow-hidden flex flex-col h-[800px]">
      {/* Header */}
      <div className="p-6 border-b border-gray-100 bg-gradient-to-r from-indigo-50 to-white flex flex-col md:flex-row justify-between items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="bg-indigo-600 p-3 rounded-2xl shadow-lg shadow-indigo-100">
            <CalendarIcon className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-xl font-bold text-gray-800 tracking-tight">Inventory Timeline</h2>
            <p className="text-xs font-semibold text-indigo-400 uppercase tracking-widest">
              {dateRange[0].toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="bg-white p-1 rounded-xl shadow-sm border border-gray-100 flex gap-1">
            <button 
              onClick={() => setViewDays(7)}
              className={`px-4 py-1.5 rounded-lg text-xs font-bold transition-all ${viewDays === 7 ? 'bg-indigo-600 text-white shadow-md' : 'text-gray-400 hover:bg-gray-50'}`}
            >
              Week
            </button>
            <button 
              onClick={() => setViewDays(14)}
              className={`px-4 py-1.5 rounded-lg text-xs font-bold transition-all ${viewDays === 14 ? 'bg-indigo-600 text-white shadow-md' : 'text-gray-400 hover:bg-gray-50'}`}
            >
              2 Weeks
            </button>
            <button 
              onClick={() => setViewDays(30)}
              className={`px-4 py-1.5 rounded-lg text-xs font-bold transition-all ${viewDays === 30 ? 'bg-indigo-600 text-white shadow-md' : 'text-gray-400 hover:bg-gray-50'}`}
            >
              Month
            </button>
          </div>

          <div className="flex items-center gap-1 bg-white p-1 rounded-xl shadow-sm border border-gray-100">
            <button onClick={prevRange} className="p-2 hover:bg-gray-50 rounded-lg transition-colors text-gray-400">
              <ChevronLeft className="w-5 h-5" />
            </button>
            <button onClick={goToToday} className="px-4 py-1.5 hover:bg-gray-50 rounded-lg text-xs font-bold text-gray-600 border-x border-gray-100">
              Today
            </button>
            <button onClick={nextRange} className="p-2 hover:bg-gray-50 rounded-lg transition-colors text-gray-400">
              <ChevronRight className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Grid */}
      <div className="flex-1 overflow-auto relative">
        <div className="min-w-max">
          {/* Timeline Header */}
          <div className="flex sticky top-0 z-30 bg-white border-b border-gray-200 shadow-sm">
            <div className="w-72 flex-shrink-0 p-4 border-r border-gray-200 bg-gray-50/50">
              <span className="text-xs font-black text-gray-400 uppercase tracking-widest">Category Availability</span>
            </div>
            {dateRange.map((date, idx) => (
              <div 
                key={idx} 
                className={`w-32 flex-shrink-0 p-3 text-center border-r border-gray-100 flex flex-col items-center justify-center gap-0.5 ${isToday(date) ? 'bg-indigo-50/30' : ''}`}
              >
                <span className={`text-[10px] font-black uppercase tracking-tighter ${isToday(date) ? 'text-indigo-600' : 'text-gray-400'}`}>
                  {getDayName(date)}
                </span>
                <span className={`text-lg font-black leading-none ${isToday(date) ? 'text-indigo-600' : 'text-gray-800'}`}>
                  {date.getDate()}
                </span>
              </div>
            ))}
          </div>

          {/* Room Type Rows */}
          <div className="divide-y divide-gray-100">
            {roomTypeGroups.map((group) => (
              <div key={group.name} className="flex group hover:bg-gray-50/50 transition-colors">
                {/* Category Info Cell */}
                <div className="w-72 flex-shrink-0 p-6 border-r border-gray-200 flex flex-col gap-2 sticky left-0 z-20 bg-white group-hover:bg-gray-50/50">
                  <span className="text-sm font-black text-gray-900 uppercase tracking-tight">{group.name}</span>
                  <div className="flex items-center gap-2">
                    <span className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Total Rooms:</span>
                    <span className="text-xs font-black text-gray-700">{group.totalRooms}</span>
                  </div>
                  {roomTypeObjects.find(rt => rt.name === group.name) && (
                    <div className="flex flex-col gap-1">
                      {/* New OTA Quota field */}
                      {(roomTypeObjects.find(rt => rt.name === group.name).online_inventory !== null && roomTypeObjects.find(rt => rt.name === group.name).online_inventory !== undefined) ? (
                        <div className="flex items-center gap-2">
                          <span className="text-[10px] font-bold text-rose-500 uppercase tracking-wider">OTA Quota:</span>
                          <span className="text-xs font-black text-rose-600">{roomTypeObjects.find(rt => rt.name === group.name).online_inventory}</span>
                        </div>
                      ) : (
                        /* Fallback to legacy total_inventory field if it was being used as quota */
                        roomTypeObjects.find(rt => rt.name === group.name).total_inventory > 0 && (
                          <div className="flex items-center gap-2">
                            <span className="text-[10px] font-bold text-emerald-500 uppercase tracking-wider">Online:</span>
                            <span className="text-xs font-black text-emerald-600">{roomTypeObjects.find(rt => rt.name === group.name).total_inventory}</span>
                          </div>
                        )
                      )}
                    </div>
                  )}
                </div>

                {/* Availability Cells */}
                <div className="flex">
                  {dateRange.map((date, idx) => {
                    const rtObj = roomTypeObjects.find(rt => rt.name === group.name);
                    const quota = (rtObj?.online_inventory !== null && rtObj?.online_inventory !== undefined) 
                                   ? Number(rtObj.online_inventory) 
                                   : (rtObj?.total_inventory > 0 ? Number(rtObj.total_inventory) : null);
                    
                    const occupancy = getOccupancyOnDate(group, date);
                    const physicalAvailable = group.totalRooms - occupancy;
                    
                    // Availability is capped by the quota if set
                    const availability = (quota !== null) 
                                         ? Math.max(0, Math.min(quota - occupancy, physicalAvailable))
                                         : physicalAvailable;

                    const isSoldOut = availability <= 0;
                    
                    return (
                      <div 
                        key={idx} 
                        className={`w-32 h-24 flex-shrink-0 border-r border-gray-100 p-2 flex flex-col items-center justify-center gap-1 transition-all ${
                          isToday(date) ? 'bg-indigo-50/10' : ''
                        } ${isSoldOut ? 'bg-rose-50/30' : 'bg-white'}`}
                      >
                        <div className={`text-xl font-black ${isSoldOut ? 'text-rose-600' : 'text-indigo-600'}`}>
                           {availability}
                        </div>
                        <div className={`text-[9px] font-black uppercase tracking-widest ${isSoldOut ? 'text-rose-400' : 'text-gray-400'}`}>
                           Available
                        </div>
                        <div className="w-full h-1.5 bg-gray-100 rounded-full overflow-hidden mt-1">
                          <motion.div 
                            initial={{ width: 0 }}
                            animate={{ width: `${(occupancy / group.totalRooms) * 100}%` }}
                            className={`h-full ${isSoldOut ? 'bg-rose-500' : 'bg-indigo-500'}`}
                          />
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Legend */}
      <div className="p-4 bg-gray-50 border-t border-gray-100 flex justify-center gap-12">
        <div className="flex items-center gap-3">
          <div className="w-4 h-4 rounded-md bg-indigo-600 shadow-sm shadow-indigo-100" />
          <span className="text-[10px] font-black text-gray-500 uppercase tracking-wider">High Availability</span>
        </div>
        <div className="flex items-center gap-3">
          <div className="w-4 h-4 rounded-md bg-rose-500 shadow-sm shadow-rose-100" />
          <span className="text-[10px] font-black text-gray-500 uppercase tracking-wider">Sold Out / Fully Booked</span>
        </div>
        <div className="flex items-center gap-3">
           <div className="px-2 py-0.5 bg-emerald-100 rounded text-emerald-700 text-[9px] font-black uppercase">Online Inv</div>
           <span className="text-[10px] font-black text-gray-500 uppercase tracking-wider">Cloud Sync Active</span>
        </div>
      </div>
    </div>
  );
};

export default BookingCalendar;
