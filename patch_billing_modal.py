import re

with open(r"d:\Zeebull\dasboard\src\pages\Billing.jsx", "r", encoding="utf-8") as f:
    content = f.read()

modal_pattern = r"\{/\* Inventory Verification Modal \*/\}.*?\n        \)\}"

modal_match = re.search(modal_pattern, content, flags=re.DOTALL)

if modal_match:
    old_modal = modal_match.group(0)
    print("Found modal block length:", len(old_modal))
    
    new_modal = """{/* Inventory Verification Modal */}
        {checkoutInventoryModal && checkoutInventoryDetails && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-xl shadow-2xl w-full max-w-5xl max-h-[90vh] overflow-y-auto">
              <div className="p-6">
                <div className="flex justify-between items-center border-b pb-4 mb-4">
                  <h2 className="text-2xl font-bold text-gray-800">Verify Room Inventory</h2>
                  <button
                    onClick={() => {
                      setCheckoutInventoryModal(null);
                      setCheckoutInventoryDetails(null);
                      setActiveRoomTab(0);
                    }}
                    className="text-gray-400 hover:text-gray-600 transition-colors"
                  >
                    <X size={24} />
                  </button>
                </div>
                
                {/* Room Tabs */}
                {checkoutInventoryDetails.room_details && checkoutInventoryDetails.room_details.length > 1 && (
                  <div className="mb-6 border-b border-gray-200">
                    <ul className="flex flex-wrap -mb-px text-sm font-medium text-center" role="tablist">
                      {checkoutInventoryDetails.room_details.map((room, idx) => (
                        <li className="mr-2" role="presentation" key={room.room_number || idx}>
                          <button
                            className={`inline-block p-4 border-b-2 rounded-t-lg transition hover:bg-gray-50 focus:outline-none ${activeRoomTab === idx ? "border-indigo-600 text-indigo-600 font-bold" : "border-transparent text-gray-500 hover:text-gray-600 hover:border-gray-300"}`}
                            onClick={() => setActiveRoomTab(idx)}
                            type="button"
                          >
                            Room {room.room_number} {activeRoomTab > idx && <span className="ml-1 text-green-500">✓</span>}
                          </button>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}

                <div className="mb-4 bg-orange-50 border border-orange-200 p-4 rounded-lg">
                  <p className="text-sm text-orange-800 font-medium">
                    Verified {activeRoomTab + 1} of {checkoutInventoryDetails.room_details?.length || 1} rooms. 
                    Please check both consumables and fixed assets. Mark any damaged assets below.
                  </p>
                </div>

                {checkoutInventoryDetails.room_details && checkoutInventoryDetails.room_details[activeRoomTab] && (
                  <>
                    {/* Fixed Assets Section */}
                    {checkoutInventoryDetails.room_details[activeRoomTab].fixed_assets && checkoutInventoryDetails.room_details[activeRoomTab].fixed_assets.length > 0 && (
                      <div className="mb-6">
                        <h3 className="text-lg font-semibold mb-3 text-red-700">Fixed Assets Check</h3>
                        <div className="bg-red-50 p-4 rounded-lg border border-red-100 overflow-x-auto">
                          <table className="w-full text-sm min-w-[700px]">
                            <thead>
                              <tr className="border-b border-red-200">
                                <th className="text-left py-2 font-medium text-red-800">Asset Name</th>
                                <th className="text-left py-2 font-medium text-red-800">Serial No.</th>
                                <th className="text-center py-2 font-medium text-red-800">Current</th>
                                <th className="text-center py-2 font-medium text-red-800">Available</th>
                                <th className="text-right py-2 font-medium text-red-800">Cost</th>
                                <th className="text-center py-2 font-medium text-red-800">Damaged?</th>
                                <th className="text-left py-2 font-medium text-red-800">Notes</th>
                              </tr>
                            </thead>
                            <tbody>
                              {checkoutInventoryDetails.room_details[activeRoomTab].fixed_assets.map((asset, idx) => (
                                <tr key={idx} className="border-b border-red-100 last:border-0 hover:bg-red-50 transition-colors">
                                  <td className="py-2 text-gray-800 font-medium whitespace-nowrap">
                                    {asset.item_name}
                                    <div className="text-xs text-gray-500">{asset.asset_tag}</div>
                                  </td>
                                  <td className="py-2 text-gray-600 border-l border-r border-red-100 px-2 font-mono text-xs whitespace-nowrap">
                                    {asset.serial_number || '-'}
                                  </td>
                                  <td className="py-2 text-center text-gray-600">{asset.current_stock}</td>
                                  <td className="py-2 text-center px-1">
                                    <input
                                      type="number"
                                      min="0"
                                      max={asset.current_stock}
                                      className={`w-14 border rounded p-1 text-center font-bold ${asset.available_stock < asset.current_stock ? 'text-red-600 bg-red-50 border-red-300' : 'text-green-600 border-gray-300'}`}
                                      value={asset.available_stock}
                                      onChange={(e) => handleUpdateAssetDamage(idx, 'available_stock', parseInt(e.target.value) || 0)}
                                    />
                                  </td>
                                  <td className="py-2 text-right text-gray-600 font-medium whitespace-nowrap">
                                    {formatCurrency(asset.replacement_cost)}
                                  </td>
                                  <td className="py-2 text-center px-2">
                                    <div className="flex items-center justify-center space-x-2">
                                      <input
                                        type="checkbox"
                                        className="w-4 h-4 text-red-600 rounded focus:ring-red-500"
                                        checked={asset.is_damaged === true}
                                        onChange={(e) => handleUpdateAssetDamage(idx, 'is_damaged', e.target.checked)}
                                      />
                                    </div>
                                  </td>
                                  <td className="py-2 pl-2">
                                    <input
                                      type="text"
                                      className="w-full border border-gray-300 rounded p-1 text-sm bg-white"
                                      placeholder="Notes..."
                                      value={asset.damage_notes || ''}
                                      onChange={(e) => handleUpdateAssetDamage(idx, 'damage_notes', e.target.value)}
                                    />
                                  </td>
                                </tr>
                              ))}
                            </tbody>
                          </table>
                        </div>
                      </div>
                    )}

                    {/* Consumables Section */}
                    {checkoutInventoryDetails.room_details[activeRoomTab].items && checkoutInventoryDetails.room_details[activeRoomTab].items.length > 0 && (
                      <div className="mb-6">
                        <h3 className="text-lg font-semibold mb-3 text-indigo-700">Consumables Check</h3>
                        <div className="bg-indigo-50 p-4 rounded-lg border border-indigo-100 overflow-x-auto">
                          <table className="w-full text-sm min-w-[700px]">
                            <thead>
                              <tr className="border-b border-indigo-200">
                                <th className="text-left py-2 font-medium text-indigo-800">Item</th>
                                <th className="text-center py-2 font-medium text-indigo-800">Current</th>
                                <th className="text-center py-2 font-medium text-indigo-800">Available</th>
                                <th className="text-center py-2 font-medium text-indigo-800">Damaged</th>
                                <th className="text-center py-2 font-medium text-indigo-800">Used/Miss</th>
                                <th className="text-left py-2 font-medium text-indigo-800">Return Loc.</th>
                              </tr>
                            </thead>
                            <tbody>
                              {checkoutInventoryDetails.room_details[activeRoomTab].items.map((item, idx) => {
                                const isDiscreteUnit = ['pcs', 'pc', 'can', 'bottle', 'unit', 'nos', 'number', 'pkt', 'pack', 'box', 'tray', 'piece', 'pieces'].includes((item.unit || 'pcs').toLowerCase());
                                return (
                                  <tr key={idx} className="border-b border-indigo-100 last:border-0 hover:bg-indigo-50 transition-colors">
                                    <td className="py-3 text-gray-800 font-medium whitespace-nowrap">
                                      {item.item_name}
                                      <div className="text-xs text-gray-500">{item.unit || 'pcs'} | {formatCurrency(item.rental_price || item.unit_price)}</div>
                                      {item.is_rentable && <span className="inline-block mt-1 px-1.5 py-0.5 bg-blue-100 text-blue-700 text-[10px] rounded border border-blue-200 shrink-0 whitespace-nowrap">Rental</span>}
                                    </td>
                                    <td className="py-3 text-center font-medium text-gray-700">{item.current_stock}</td>
                                    <td className="py-3 text-center px-1">
                                      <input
                                        type="number"
                                        min="0"
                                        max={item.current_stock}
                                        step={isDiscreteUnit ? "1" : "0.01"}
                                        className={`w-16 border rounded p-1 text-center font-bold shadow-sm focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 ${item.available_stock < item.current_stock ? 'text-orange-600 bg-orange-50 border-orange-300' : 'text-green-600 border-gray-300'}`}
                                        value={item.available_stock}
                                        onChange={(e) => handleUpdateInventoryVerification(idx, 'available_stock', e.target.value)}
                                      />
                                    </td>
                                    <td className="py-3 text-center px-1">
                                      <input
                                        type="number"
                                        min="0"
                                        max={Math.max(0, item.current_stock - (item.available_stock || 0))}
                                        step={isDiscreteUnit ? "1" : "0.01"}
                                        className="w-16 border border-gray-300 rounded p-1 text-center font-medium shadow-sm focus:ring-1 focus:ring-red-500 text-red-600 bg-red-50"
                                        value={item.damage_qty || 0}
                                        onChange={(e) => handleUpdateInventoryVerification(idx, 'damage_qty', e.target.value)}
                                      />
                                    </td>
                                    <td className="py-3 text-center whitespace-nowrap">
                                      {item.is_rentable ? (
                                        <div className="font-bold text-red-600">Miss: {item.missing_qty || 0}</div>
                                      ) : (
                                        <div className="font-bold text-orange-600">Used: {item.used_qty || 0}</div>
                                      )}
                                    </td>
                                    <td className="py-3 pl-2 min-w-[140px]">
                                      <select
                                        className="w-full border border-gray-300 rounded p-1.5 text-sm bg-white focus:ring-indigo-500 focus:border-indigo-500 shadow-sm"
                                        value={item.return_location_id || ""}
                                        onChange={(e) => handleUpdateReturnLocation(idx, e.target.value)}
                                      >
                                        <option value="">Move to (Optional)</option>
                                        {returnLocations.map(loc => (
                                          <option key={loc.id} value={loc.id}>{loc.name}</option>
                                        ))}
                                      </select>
                                    </td>
                                  </tr>
                                );
                              })}
                            </tbody>
                          </table>
                        </div>
                      </div>
                    )}
                  </>
                )}

                <div className="mt-8 pt-4 border-t border-gray-200">
                  <p className="text-sm text-gray-500 mb-4 bg-gray-50 p-2 rounded">
                    <strong>Note:</strong> Items marked as missing or damaged will add charges to the final bill. Stock marked manually as used (for extra issue consumables) adds charges dynamically based on your issue price settings.
                  </p>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Audit Notes (Optional)
                  </label>
                  <textarea
                    className="w-full border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 p-2 text-sm"
                    rows="2"
                    placeholder="Enter any remarks for the checkout..."
                    id="inventoryVerifyNotes"
                  ></textarea>
                </div>
              </div>
              <div className="bg-gray-50 px-6 py-4 border-t border-gray-200 flex flex-col sm:flex-row justify-between items-center space-y-3 sm:space-y-0">
                <div className="text-sm text-gray-600 font-medium">
                  {checkoutInventoryDetails.room_details && checkoutInventoryDetails.room_details.length > 1 && (
                    <span>
                      {activeRoomTab < checkoutInventoryDetails.room_details.length - 1 ? (
                        <button
                          type="button"
                          onClick={() => setActiveRoomTab(prev => prev + 1)}
                          className="text-indigo-600 hover:text-indigo-800 font-bold underline"
                        >
                          Next: Room {checkoutInventoryDetails.room_details[activeRoomTab + 1].room_number} &rarr;
                        </button>
                      ) : (
                        <span className="text-green-600 font-bold">✓ All rooms reviewed</span>
                      )}
                    </span>
                  )}
                </div>
                <div className="flex space-x-3">
                  <button
                    type="button"
                    onClick={() => {
                      setCheckoutInventoryModal(null);
                      setCheckoutInventoryDetails(null);
                      setActiveRoomTab(0);
                    }}
                    className="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    onClick={() => handleSubmitInventoryCheck(document.getElementById('inventoryVerifyNotes')?.value)}
                    disabled={checkingInventory}
                    className={`inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white ${checkingInventory ? 'bg-indigo-400 cursor-not-allowed' : 'bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500'}`}
                  >
                    {checkingInventory ? 'Verifying...' : 'Confirm Verification'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}"""
    
    content = content.replace(old_modal, new_modal)
    
    with open(r"d:\Zeebull\dasboard\src\pages\Billing.jsx", "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Patch applied!")
else:
    print("Could not find modal match")

