--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.working_logs DROP CONSTRAINT IF EXISTS working_logs_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_reported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_assigned_to_fkey;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_asset_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_order_parts DROP CONSTRAINT IF EXISTS work_order_parts_work_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_order_parts DROP CONSTRAINT IF EXISTS work_order_parts_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_order_part_issues DROP CONSTRAINT IF EXISTS work_order_part_issues_work_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_order_part_issues DROP CONSTRAINT IF EXISTS work_order_part_issues_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_order_part_issues DROP CONSTRAINT IF EXISTS work_order_part_issues_issued_by_fkey;
ALTER TABLE IF EXISTS ONLY public.work_order_part_issues DROP CONSTRAINT IF EXISTS work_order_part_issues_from_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.waste_logs DROP CONSTRAINT IF EXISTS waste_logs_reported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.waste_logs DROP CONSTRAINT IF EXISTS waste_logs_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.wastage_logs DROP CONSTRAINT IF EXISTS wastage_logs_logged_by_fkey;
ALTER TABLE IF EXISTS ONLY public.wastage_logs DROP CONSTRAINT IF EXISTS wastage_logs_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.wastage_logs DROP CONSTRAINT IF EXISTS wastage_logs_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.vendor_performance DROP CONSTRAINT IF EXISTS vendor_performance_vendor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.vendor_items DROP CONSTRAINT IF EXISTS vendor_items_vendor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.vendor_items DROP CONSTRAINT IF EXISTS vendor_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.uom_conversions DROP CONSTRAINT IF EXISTS uom_conversions_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_usage DROP CONSTRAINT IF EXISTS stock_usage_used_by_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_usage DROP CONSTRAINT IF EXISTS stock_usage_recipe_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_usage DROP CONSTRAINT IF EXISTS stock_usage_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_usage DROP CONSTRAINT IF EXISTS stock_usage_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_usage DROP CONSTRAINT IF EXISTS stock_usage_food_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_requisitions DROP CONSTRAINT IF EXISTS stock_requisitions_requested_by_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_requisitions DROP CONSTRAINT IF EXISTS stock_requisitions_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_requisition_details DROP CONSTRAINT IF EXISTS stock_requisition_details_requisition_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_requisition_details DROP CONSTRAINT IF EXISTS stock_requisition_details_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_movements DROP CONSTRAINT IF EXISTS stock_movements_to_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_movements DROP CONSTRAINT IF EXISTS stock_movements_moved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_movements DROP CONSTRAINT IF EXISTS stock_movements_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_movements DROP CONSTRAINT IF EXISTS stock_movements_from_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_levels DROP CONSTRAINT IF EXISTS stock_levels_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_levels DROP CONSTRAINT IF EXISTS stock_levels_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_issues DROP CONSTRAINT IF EXISTS stock_issues_requisition_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_issues DROP CONSTRAINT IF EXISTS stock_issues_issued_by_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_issue_details DROP CONSTRAINT IF EXISTS stock_issue_details_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.stock_issue_details DROP CONSTRAINT IF EXISTS stock_issue_details_issue_id_fkey;
ALTER TABLE IF EXISTS ONLY public.service_requests DROP CONSTRAINT IF EXISTS service_requests_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.service_requests DROP CONSTRAINT IF EXISTS service_requests_food_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.service_requests DROP CONSTRAINT IF EXISTS service_requests_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.service_inventory_items DROP CONSTRAINT IF EXISTS service_inventory_items_service_id_fkey;
ALTER TABLE IF EXISTS ONLY public.service_inventory_items DROP CONSTRAINT IF EXISTS service_inventory_items_inventory_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.service_images DROP CONSTRAINT IF EXISTS service_images_service_id_fkey;
ALTER TABLE IF EXISTS ONLY public.security_uniforms DROP CONSTRAINT IF EXISTS security_uniforms_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.security_uniforms DROP CONSTRAINT IF EXISTS security_uniforms_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.security_maintenance DROP CONSTRAINT IF EXISTS security_maintenance_performed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.security_maintenance DROP CONSTRAINT IF EXISTS security_maintenance_equipment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.security_equipment DROP CONSTRAINT IF EXISTS security_equipment_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.security_equipment DROP CONSTRAINT IF EXISTS security_equipment_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.security_equipment DROP CONSTRAINT IF EXISTS security_equipment_assigned_to_fkey;
ALTER TABLE IF EXISTS ONLY public.rooms DROP CONSTRAINT IF EXISTS rooms_inventory_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_inventory_items DROP CONSTRAINT IF EXISTS room_inventory_items_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_inventory_items DROP CONSTRAINT IF EXISTS room_inventory_items_last_audited_by_fkey;
ALTER TABLE IF EXISTS ONLY public.room_inventory_items DROP CONSTRAINT IF EXISTS room_inventory_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_inventory_audits DROP CONSTRAINT IF EXISTS room_inventory_audits_room_inventory_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_inventory_audits DROP CONSTRAINT IF EXISTS room_inventory_audits_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_inventory_audits DROP CONSTRAINT IF EXISTS room_inventory_audits_audited_by_fkey;
ALTER TABLE IF EXISTS ONLY public.room_consumable_items DROP CONSTRAINT IF EXISTS room_consumable_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_consumable_items DROP CONSTRAINT IF EXISTS room_consumable_items_assignment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_consumable_assignments DROP CONSTRAINT IF EXISTS room_consumable_assignments_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_consumable_assignments DROP CONSTRAINT IF EXISTS room_consumable_assignments_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_consumable_assignments DROP CONSTRAINT IF EXISTS room_consumable_assignments_assigned_by_fkey;
ALTER TABLE IF EXISTS ONLY public.room_assets DROP CONSTRAINT IF EXISTS room_assets_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.room_assets DROP CONSTRAINT IF EXISTS room_assets_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.restock_alerts DROP CONSTRAINT IF EXISTS restock_alerts_resolved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.restock_alerts DROP CONSTRAINT IF EXISTS restock_alerts_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.restock_alerts DROP CONSTRAINT IF EXISTS restock_alerts_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.restock_alerts DROP CONSTRAINT IF EXISTS restock_alerts_acknowledged_by_fkey;
ALTER TABLE IF EXISTS ONLY public.recipes DROP CONSTRAINT IF EXISTS recipes_food_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.recipe_ingredients DROP CONSTRAINT IF EXISTS recipe_ingredients_recipe_id_fkey;
ALTER TABLE IF EXISTS ONLY public.recipe_ingredients DROP CONSTRAINT IF EXISTS recipe_ingredients_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_orders DROP CONSTRAINT IF EXISTS purchase_orders_indent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_orders DROP CONSTRAINT IF EXISTS purchase_orders_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_orders DROP CONSTRAINT IF EXISTS purchase_orders_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_masters DROP CONSTRAINT IF EXISTS purchase_masters_vendor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_masters DROP CONSTRAINT IF EXISTS purchase_masters_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_entry_items DROP CONSTRAINT IF EXISTS purchase_entry_items_stock_level_id_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_entry_items DROP CONSTRAINT IF EXISTS purchase_entry_items_purchase_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_entry_items DROP CONSTRAINT IF EXISTS purchase_entry_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_entries DROP CONSTRAINT IF EXISTS purchase_entries_vendor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_entries DROP CONSTRAINT IF EXISTS purchase_entries_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_entries DROP CONSTRAINT IF EXISTS purchase_entries_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_details DROP CONSTRAINT IF EXISTS purchase_details_purchase_master_id_fkey;
ALTER TABLE IF EXISTS ONLY public.purchase_details DROP CONSTRAINT IF EXISTS purchase_details_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.po_items DROP CONSTRAINT IF EXISTS po_items_po_id_fkey;
ALTER TABLE IF EXISTS ONLY public.po_items DROP CONSTRAINT IF EXISTS po_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.perishable_batches DROP CONSTRAINT IF EXISTS perishable_batches_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.perishable_batches DROP CONSTRAINT IF EXISTS perishable_batches_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_images DROP CONSTRAINT IF EXISTS package_images_package_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_bookings DROP CONSTRAINT IF EXISTS package_bookings_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_bookings DROP CONSTRAINT IF EXISTS package_bookings_package_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_booking_rooms DROP CONSTRAINT IF EXISTS package_booking_rooms_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_booking_rooms DROP CONSTRAINT IF EXISTS package_booking_rooms_package_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.outlets DROP CONSTRAINT IF EXISTS outlets_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.outlet_stocks DROP CONSTRAINT IF EXISTS outlet_stocks_outlet_id_fkey;
ALTER TABLE IF EXISTS ONLY public.outlet_stocks DROP CONSTRAINT IF EXISTS outlet_stocks_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.office_requisitions DROP CONSTRAINT IF EXISTS office_requisitions_supervisor_approval_fkey;
ALTER TABLE IF EXISTS ONLY public.office_requisitions DROP CONSTRAINT IF EXISTS office_requisitions_requested_by_fkey;
ALTER TABLE IF EXISTS ONLY public.office_requisitions DROP CONSTRAINT IF EXISTS office_requisitions_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.office_requisitions DROP CONSTRAINT IF EXISTS office_requisitions_issued_by_fkey;
ALTER TABLE IF EXISTS ONLY public.office_requisitions DROP CONSTRAINT IF EXISTS office_requisitions_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.office_requisitions DROP CONSTRAINT IF EXISTS office_requisitions_admin_approval_fkey;
ALTER TABLE IF EXISTS ONLY public.office_inventory_items DROP CONSTRAINT IF EXISTS office_inventory_items_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.office_inventory_items DROP CONSTRAINT IF EXISTS office_inventory_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.office_inventory_items DROP CONSTRAINT IF EXISTS office_inventory_items_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.office_inventory_items DROP CONSTRAINT IF EXISTS office_inventory_items_assigned_to_fkey;
ALTER TABLE IF EXISTS ONLY public.maintenance_tickets DROP CONSTRAINT IF EXISTS maintenance_tickets_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.maintenance_tickets DROP CONSTRAINT IF EXISTS maintenance_tickets_reported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.maintenance_tickets DROP CONSTRAINT IF EXISTS maintenance_tickets_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.maintenance_tickets DROP CONSTRAINT IF EXISTS maintenance_tickets_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.maintenance_tickets DROP CONSTRAINT IF EXISTS maintenance_tickets_assigned_to_fkey;
ALTER TABLE IF EXISTS ONLY public.lost_found DROP CONSTRAINT IF EXISTS lost_found_found_by_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.locations DROP CONSTRAINT IF EXISTS locations_parent_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.location_stocks DROP CONSTRAINT IF EXISTS location_stocks_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.location_stocks DROP CONSTRAINT IF EXISTS location_stocks_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.linen_wash_logs DROP CONSTRAINT IF EXISTS linen_wash_logs_linen_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.linen_stocks DROP CONSTRAINT IF EXISTS linen_stocks_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.linen_stocks DROP CONSTRAINT IF EXISTS linen_stocks_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.linen_movements DROP CONSTRAINT IF EXISTS linen_movements_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.linen_movements DROP CONSTRAINT IF EXISTS linen_movements_moved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.linen_movements DROP CONSTRAINT IF EXISTS linen_movements_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.linen_items DROP CONSTRAINT IF EXISTS linen_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.linen_items DROP CONSTRAINT IF EXISTS linen_items_current_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.linen_items DROP CONSTRAINT IF EXISTS linen_items_current_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.leaves DROP CONSTRAINT IF EXISTS leaves_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.laundry_services DROP CONSTRAINT IF EXISTS laundry_services_vendor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.key_movements DROP CONSTRAINT IF EXISTS key_movements_to_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.key_movements DROP CONSTRAINT IF EXISTS key_movements_key_id_fkey;
ALTER TABLE IF EXISTS ONLY public.key_movements DROP CONSTRAINT IF EXISTS key_movements_from_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.key_management DROP CONSTRAINT IF EXISTS key_management_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.key_management DROP CONSTRAINT IF EXISTS key_management_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.key_management DROP CONSTRAINT IF EXISTS key_management_current_holder_fkey;
ALTER TABLE IF EXISTS ONLY public.journal_entry_lines DROP CONSTRAINT IF EXISTS journal_entry_lines_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.journal_entry_lines DROP CONSTRAINT IF EXISTS journal_entry_lines_debit_ledger_id_fkey;
ALTER TABLE IF EXISTS ONLY public.journal_entry_lines DROP CONSTRAINT IF EXISTS journal_entry_lines_credit_ledger_id_fkey;
ALTER TABLE IF EXISTS ONLY public.journal_entries DROP CONSTRAINT IF EXISTS journal_entries_reversed_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.journal_entries DROP CONSTRAINT IF EXISTS journal_entries_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.inventory_transactions DROP CONSTRAINT IF EXISTS inventory_transactions_purchase_master_id_fkey;
ALTER TABLE IF EXISTS ONLY public.inventory_transactions DROP CONSTRAINT IF EXISTS inventory_transactions_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.inventory_transactions DROP CONSTRAINT IF EXISTS inventory_transactions_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.inventory_items DROP CONSTRAINT IF EXISTS inventory_items_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.inventory_items DROP CONSTRAINT IF EXISTS inventory_items_base_uom_id_fkey;
ALTER TABLE IF EXISTS ONLY public.inventory_expenses DROP CONSTRAINT IF EXISTS inventory_expenses_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.inventory_expenses DROP CONSTRAINT IF EXISTS inventory_expenses_issued_by_fkey;
ALTER TABLE IF EXISTS ONLY public.inventory_expenses DROP CONSTRAINT IF EXISTS inventory_expenses_cost_center_id_fkey;
ALTER TABLE IF EXISTS ONLY public.indents DROP CONSTRAINT IF EXISTS indents_requested_to_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.indents DROP CONSTRAINT IF EXISTS indents_requested_from_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.indents DROP CONSTRAINT IF EXISTS indents_requested_by_fkey;
ALTER TABLE IF EXISTS ONLY public.indents DROP CONSTRAINT IF EXISTS indents_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.indent_items DROP CONSTRAINT IF EXISTS indent_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.indent_items DROP CONSTRAINT IF EXISTS indent_items_indent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.grn_items DROP CONSTRAINT IF EXISTS grn_items_po_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.grn_items DROP CONSTRAINT IF EXISTS grn_items_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.grn_items DROP CONSTRAINT IF EXISTS grn_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.grn_items DROP CONSTRAINT IF EXISTS grn_items_grn_id_fkey;
ALTER TABLE IF EXISTS ONLY public.goods_received_notes DROP CONSTRAINT IF EXISTS goods_received_notes_verified_by_fkey;
ALTER TABLE IF EXISTS ONLY public.goods_received_notes DROP CONSTRAINT IF EXISTS goods_received_notes_received_by_fkey;
ALTER TABLE IF EXISTS ONLY public.goods_received_notes DROP CONSTRAINT IF EXISTS goods_received_notes_po_id_fkey;
ALTER TABLE IF EXISTS ONLY public.food_orders DROP CONSTRAINT IF EXISTS food_orders_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.food_orders DROP CONSTRAINT IF EXISTS food_orders_assigned_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.food_order_items DROP CONSTRAINT IF EXISTS food_order_items_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.food_order_items DROP CONSTRAINT IF EXISTS food_order_items_food_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.food_items DROP CONSTRAINT IF EXISTS food_items_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.food_item_images DROP CONSTRAINT IF EXISTS food_item_images_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.waste_logs DROP CONSTRAINT IF EXISTS fk_waste_logs_location;
ALTER TABLE IF EXISTS ONLY public.waste_logs DROP CONSTRAINT IF EXISTS fk_waste_logs_food_item_id;
ALTER TABLE IF EXISTS ONLY public.stock_issues DROP CONSTRAINT IF EXISTS fk_stock_issues_source_location;
ALTER TABLE IF EXISTS ONLY public.stock_issues DROP CONSTRAINT IF EXISTS fk_stock_issues_dest_location;
ALTER TABLE IF EXISTS ONLY public.recipe_ingredients DROP CONSTRAINT IF EXISTS fk_recipe_ingredients_inventory_item;
ALTER TABLE IF EXISTS ONLY public.purchase_masters DROP CONSTRAINT IF EXISTS fk_purchase_masters_destination_location_id;
ALTER TABLE IF EXISTS ONLY public.expenses DROP CONSTRAINT IF EXISTS fk_expenses_vendor_id;
ALTER TABLE IF EXISTS ONLY public.first_aid_kits DROP CONSTRAINT IF EXISTS first_aid_kits_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.first_aid_kits DROP CONSTRAINT IF EXISTS first_aid_kits_checked_by_fkey;
ALTER TABLE IF EXISTS ONLY public.first_aid_kit_items DROP CONSTRAINT IF EXISTS first_aid_kit_items_kit_id_fkey;
ALTER TABLE IF EXISTS ONLY public.first_aid_kit_items DROP CONSTRAINT IF EXISTS first_aid_kit_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_maintenance DROP CONSTRAINT IF EXISTS fire_safety_maintenance_performed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_maintenance DROP CONSTRAINT IF EXISTS fire_safety_maintenance_equipment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_inspections DROP CONSTRAINT IF EXISTS fire_safety_inspections_inspected_by_fkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_inspections DROP CONSTRAINT IF EXISTS fire_safety_inspections_equipment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_incidents DROP CONSTRAINT IF EXISTS fire_safety_incidents_reported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_incidents DROP CONSTRAINT IF EXISTS fire_safety_incidents_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_incidents DROP CONSTRAINT IF EXISTS fire_safety_incidents_equipment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_equipment DROP CONSTRAINT IF EXISTS fire_safety_equipment_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_equipment DROP CONSTRAINT IF EXISTS fire_safety_equipment_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.expiry_alerts DROP CONSTRAINT IF EXISTS expiry_alerts_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.expiry_alerts DROP CONSTRAINT IF EXISTS expiry_alerts_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.expiry_alerts DROP CONSTRAINT IF EXISTS expiry_alerts_acknowledged_by_fkey;
ALTER TABLE IF EXISTS ONLY public.expenses DROP CONSTRAINT IF EXISTS expenses_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.eod_audits DROP CONSTRAINT IF EXISTS eod_audits_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.eod_audits DROP CONSTRAINT IF EXISTS eod_audits_audited_by_fkey;
ALTER TABLE IF EXISTS ONLY public.eod_audit_items DROP CONSTRAINT IF EXISTS eod_audit_items_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.eod_audit_items DROP CONSTRAINT IF EXISTS eod_audit_items_audit_id_fkey;
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS employees_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.employee_inventory_assignments DROP CONSTRAINT IF EXISTS employee_inventory_assignments_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.employee_inventory_assignments DROP CONSTRAINT IF EXISTS employee_inventory_assignments_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.employee_inventory_assignments DROP CONSTRAINT IF EXISTS employee_inventory_assignments_assigned_service_id_fkey;
ALTER TABLE IF EXISTS ONLY public.damage_reports DROP CONSTRAINT IF EXISTS damage_reports_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.damage_reports DROP CONSTRAINT IF EXISTS damage_reports_reported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.damage_reports DROP CONSTRAINT IF EXISTS damage_reports_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.damage_reports DROP CONSTRAINT IF EXISTS damage_reports_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.damage_reports DROP CONSTRAINT IF EXISTS damage_reports_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.consumable_usage DROP CONSTRAINT IF EXISTS consumable_usage_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.consumable_usage DROP CONSTRAINT IF EXISTS consumable_usage_recorded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.consumable_usage DROP CONSTRAINT IF EXISTS consumable_usage_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.consumable_usage DROP CONSTRAINT IF EXISTS consumable_usage_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checkouts DROP CONSTRAINT IF EXISTS checkouts_package_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checkouts DROP CONSTRAINT IF EXISTS checkouts_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checkout_verifications DROP CONSTRAINT IF EXISTS checkout_verifications_checkout_request_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checkout_verifications DROP CONSTRAINT IF EXISTS checkout_verifications_checkout_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checkout_requests DROP CONSTRAINT IF EXISTS checkout_requests_package_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checkout_requests DROP CONSTRAINT IF EXISTS checkout_requests_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checkout_requests DROP CONSTRAINT IF EXISTS checkout_requests_checkout_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checkout_requests DROP CONSTRAINT IF EXISTS checkout_requests_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checkout_payments DROP CONSTRAINT IF EXISTS checkout_payments_checkout_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checklist_responses DROP CONSTRAINT IF EXISTS checklist_responses_responded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.checklist_responses DROP CONSTRAINT IF EXISTS checklist_responses_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checklist_responses DROP CONSTRAINT IF EXISTS checklist_responses_execution_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checklist_items DROP CONSTRAINT IF EXISTS checklist_items_checklist_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checklist_executions DROP CONSTRAINT IF EXISTS checklist_executions_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checklist_executions DROP CONSTRAINT IF EXISTS checklist_executions_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.checklist_executions DROP CONSTRAINT IF EXISTS checklist_executions_executed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.checklist_executions DROP CONSTRAINT IF EXISTS checklist_executions_checklist_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bookings DROP CONSTRAINT IF EXISTS bookings_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.booking_rooms DROP CONSTRAINT IF EXISTS booking_rooms_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.booking_rooms DROP CONSTRAINT IF EXISTS booking_rooms_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_discrepancies DROP CONSTRAINT IF EXISTS audit_discrepancies_resolved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_discrepancies DROP CONSTRAINT IF EXISTS audit_discrepancies_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_discrepancies DROP CONSTRAINT IF EXISTS audit_discrepancies_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_discrepancies DROP CONSTRAINT IF EXISTS audit_discrepancies_audit_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendances DROP CONSTRAINT IF EXISTS attendances_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assigned_services DROP CONSTRAINT IF EXISTS assigned_services_service_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assigned_services DROP CONSTRAINT IF EXISTS assigned_services_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assigned_services DROP CONSTRAINT IF EXISTS assigned_services_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_registry DROP CONSTRAINT IF EXISTS asset_registry_purchase_master_id_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_registry DROP CONSTRAINT IF EXISTS asset_registry_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_registry DROP CONSTRAINT IF EXISTS asset_registry_current_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_mappings DROP CONSTRAINT IF EXISTS asset_mappings_location_id_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_mappings DROP CONSTRAINT IF EXISTS asset_mappings_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_mappings DROP CONSTRAINT IF EXISTS asset_mappings_assigned_by_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_maintenance DROP CONSTRAINT IF EXISTS asset_maintenance_performed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_maintenance DROP CONSTRAINT IF EXISTS asset_maintenance_asset_id_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_inspections DROP CONSTRAINT IF EXISTS asset_inspections_inspected_by_fkey;
ALTER TABLE IF EXISTS ONLY public.asset_inspections DROP CONSTRAINT IF EXISTS asset_inspections_asset_id_fkey;
ALTER TABLE IF EXISTS ONLY public.approval_requests DROP CONSTRAINT IF EXISTS approval_requests_requested_by_fkey;
ALTER TABLE IF EXISTS ONLY public.approval_requests DROP CONSTRAINT IF EXISTS approval_requests_level_3_approver_fkey;
ALTER TABLE IF EXISTS ONLY public.approval_requests DROP CONSTRAINT IF EXISTS approval_requests_level_2_approver_fkey;
ALTER TABLE IF EXISTS ONLY public.approval_requests DROP CONSTRAINT IF EXISTS approval_requests_level_1_approver_fkey;
ALTER TABLE IF EXISTS ONLY public.approval_matrices DROP CONSTRAINT IF EXISTS approval_matrices_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account_ledgers DROP CONSTRAINT IF EXISTS account_ledgers_group_id_fkey;
DROP TRIGGER IF EXISTS trigger_set_uom ON public.recipe_ingredients;
DROP TRIGGER IF EXISTS trigger_set_item_id ON public.recipe_ingredients;
DROP INDEX IF EXISTS public.ix_working_logs_id;
DROP INDEX IF EXISTS public.ix_work_orders_id;
DROP INDEX IF EXISTS public.ix_work_order_parts_id;
DROP INDEX IF EXISTS public.ix_work_order_part_issues_id;
DROP INDEX IF EXISTS public.ix_waste_logs_id;
DROP INDEX IF EXISTS public.ix_wastage_logs_id;
DROP INDEX IF EXISTS public.ix_vouchers_id;
DROP INDEX IF EXISTS public.ix_vendors_id;
DROP INDEX IF EXISTS public.ix_vendor_performance_id;
DROP INDEX IF EXISTS public.ix_vendor_items_id;
DROP INDEX IF EXISTS public.ix_users_id;
DROP INDEX IF EXISTS public.ix_users_email;
DROP INDEX IF EXISTS public.ix_uom_conversions_id;
DROP INDEX IF EXISTS public.ix_units_of_measurement_id;
DROP INDEX IF EXISTS public.ix_system_settings_key;
DROP INDEX IF EXISTS public.ix_system_settings_id;
DROP INDEX IF EXISTS public.ix_stock_usage_id;
DROP INDEX IF EXISTS public.ix_stock_requisitions_requisition_number;
DROP INDEX IF EXISTS public.ix_stock_requisitions_id;
DROP INDEX IF EXISTS public.ix_stock_requisition_details_id;
DROP INDEX IF EXISTS public.ix_stock_movements_id;
DROP INDEX IF EXISTS public.ix_stock_levels_id;
DROP INDEX IF EXISTS public.ix_stock_issues_issue_number;
DROP INDEX IF EXISTS public.ix_stock_issues_id;
DROP INDEX IF EXISTS public.ix_stock_issue_details_id;
DROP INDEX IF EXISTS public.ix_signature_experiences_id;
DROP INDEX IF EXISTS public.ix_services_id;
DROP INDEX IF EXISTS public.ix_service_requests_id;
DROP INDEX IF EXISTS public.ix_service_images_id;
DROP INDEX IF EXISTS public.ix_security_uniforms_id;
DROP INDEX IF EXISTS public.ix_security_maintenance_id;
DROP INDEX IF EXISTS public.ix_security_equipment_id;
DROP INDEX IF EXISTS public.ix_rooms_id;
DROP INDEX IF EXISTS public.ix_room_inventory_items_id;
DROP INDEX IF EXISTS public.ix_room_inventory_audits_id;
DROP INDEX IF EXISTS public.ix_room_consumable_items_id;
DROP INDEX IF EXISTS public.ix_room_consumable_assignments_id;
DROP INDEX IF EXISTS public.ix_room_assets_id;
DROP INDEX IF EXISTS public.ix_roles_id;
DROP INDEX IF EXISTS public.ix_reviews_id;
DROP INDEX IF EXISTS public.ix_restock_alerts_id;
DROP INDEX IF EXISTS public.ix_resort_info_id;
DROP INDEX IF EXISTS public.ix_recipes_id;
DROP INDEX IF EXISTS public.ix_recipe_ingredients_id;
DROP INDEX IF EXISTS public.ix_purchase_orders_id;
DROP INDEX IF EXISTS public.ix_purchase_masters_purchase_number;
DROP INDEX IF EXISTS public.ix_purchase_masters_invoice_number;
DROP INDEX IF EXISTS public.ix_purchase_masters_id;
DROP INDEX IF EXISTS public.ix_purchase_entry_items_id;
DROP INDEX IF EXISTS public.ix_purchase_entries_id;
DROP INDEX IF EXISTS public.ix_purchase_details_id;
DROP INDEX IF EXISTS public.ix_po_items_id;
DROP INDEX IF EXISTS public.ix_plan_weddings_id;
DROP INDEX IF EXISTS public.ix_perishable_batches_id;
DROP INDEX IF EXISTS public.ix_payments_id;
DROP INDEX IF EXISTS public.ix_packages_id;
DROP INDEX IF EXISTS public.ix_package_images_id;
DROP INDEX IF EXISTS public.ix_package_bookings_id;
DROP INDEX IF EXISTS public.ix_package_booking_rooms_id;
DROP INDEX IF EXISTS public.ix_outlets_id;
DROP INDEX IF EXISTS public.ix_outlet_stocks_id;
DROP INDEX IF EXISTS public.ix_office_requisitions_id;
DROP INDEX IF EXISTS public.ix_office_inventory_items_id;
DROP INDEX IF EXISTS public.ix_notifications_id;
DROP INDEX IF EXISTS public.ix_nearby_attractions_id;
DROP INDEX IF EXISTS public.ix_nearby_attraction_banners_id;
DROP INDEX IF EXISTS public.ix_maintenance_tickets_id;
DROP INDEX IF EXISTS public.ix_lost_found_id;
DROP INDEX IF EXISTS public.ix_locations_id;
DROP INDEX IF EXISTS public.ix_location_stocks_id;
DROP INDEX IF EXISTS public.ix_linen_wash_logs_id;
DROP INDEX IF EXISTS public.ix_linen_stocks_id;
DROP INDEX IF EXISTS public.ix_linen_movements_id;
DROP INDEX IF EXISTS public.ix_linen_items_id;
DROP INDEX IF EXISTS public.ix_legal_documents_id;
DROP INDEX IF EXISTS public.ix_leaves_id;
DROP INDEX IF EXISTS public.ix_laundry_services_id;
DROP INDEX IF EXISTS public.ix_key_movements_id;
DROP INDEX IF EXISTS public.ix_key_management_id;
DROP INDEX IF EXISTS public.ix_journal_entry_lines_id;
DROP INDEX IF EXISTS public.ix_journal_entries_id;
DROP INDEX IF EXISTS public.ix_inventory_transactions_id;
DROP INDEX IF EXISTS public.ix_inventory_items_id;
DROP INDEX IF EXISTS public.ix_inventory_expenses_id;
DROP INDEX IF EXISTS public.ix_inventory_categories_id;
DROP INDEX IF EXISTS public.ix_indents_id;
DROP INDEX IF EXISTS public.ix_indent_items_id;
DROP INDEX IF EXISTS public.ix_header_banner_id;
DROP INDEX IF EXISTS public.ix_guest_suggestions_id;
DROP INDEX IF EXISTS public.ix_grn_items_id;
DROP INDEX IF EXISTS public.ix_goods_received_notes_id;
DROP INDEX IF EXISTS public.ix_gallery_id;
DROP INDEX IF EXISTS public.ix_food_orders_id;
DROP INDEX IF EXISTS public.ix_food_order_items_id;
DROP INDEX IF EXISTS public.ix_food_items_id;
DROP INDEX IF EXISTS public.ix_food_item_images_id;
DROP INDEX IF EXISTS public.ix_food_categories_id;
DROP INDEX IF EXISTS public.ix_first_aid_kits_id;
DROP INDEX IF EXISTS public.ix_first_aid_kit_items_id;
DROP INDEX IF EXISTS public.ix_fire_safety_maintenance_id;
DROP INDEX IF EXISTS public.ix_fire_safety_inspections_id;
DROP INDEX IF EXISTS public.ix_fire_safety_incidents_id;
DROP INDEX IF EXISTS public.ix_fire_safety_equipment_id;
DROP INDEX IF EXISTS public.ix_expiry_alerts_id;
DROP INDEX IF EXISTS public.ix_expenses_self_invoice_number;
DROP INDEX IF EXISTS public.ix_expenses_id;
DROP INDEX IF EXISTS public.ix_eod_audits_id;
DROP INDEX IF EXISTS public.ix_eod_audit_items_id;
DROP INDEX IF EXISTS public.ix_employees_id;
DROP INDEX IF EXISTS public.ix_employee_inventory_assignments_id;
DROP INDEX IF EXISTS public.ix_damage_reports_id;
DROP INDEX IF EXISTS public.ix_cost_centers_id;
DROP INDEX IF EXISTS public.ix_consumable_usage_id;
DROP INDEX IF EXISTS public.ix_checkouts_id;
DROP INDEX IF EXISTS public.ix_checkout_verifications_id;
DROP INDEX IF EXISTS public.ix_checkout_requests_id;
DROP INDEX IF EXISTS public.ix_checkout_payments_id;
DROP INDEX IF EXISTS public.ix_checklists_id;
DROP INDEX IF EXISTS public.ix_checklist_responses_id;
DROP INDEX IF EXISTS public.ix_checklist_items_id;
DROP INDEX IF EXISTS public.ix_checklist_executions_id;
DROP INDEX IF EXISTS public.ix_check_availability_id;
DROP INDEX IF EXISTS public.ix_bookings_id;
DROP INDEX IF EXISTS public.ix_booking_rooms_id;
DROP INDEX IF EXISTS public.ix_audit_discrepancies_id;
DROP INDEX IF EXISTS public.ix_attendances_id;
DROP INDEX IF EXISTS public.ix_assigned_services_id;
DROP INDEX IF EXISTS public.ix_asset_registry_id;
DROP INDEX IF EXISTS public.ix_asset_registry_asset_tag_id;
DROP INDEX IF EXISTS public.ix_asset_mappings_id;
DROP INDEX IF EXISTS public.ix_asset_maintenance_id;
DROP INDEX IF EXISTS public.ix_asset_inspections_id;
DROP INDEX IF EXISTS public.ix_approval_requests_id;
DROP INDEX IF EXISTS public.ix_approval_matrices_id;
DROP INDEX IF EXISTS public.ix_account_ledgers_id;
DROP INDEX IF EXISTS public.ix_account_groups_id;
DROP INDEX IF EXISTS public.idx_waste_logs_log_number;
DROP INDEX IF EXISTS public.idx_room_status;
DROP INDEX IF EXISTS public.idx_room_number;
DROP INDEX IF EXISTS public.idx_recipe_ingredients_inventory_item_id;
DROP INDEX IF EXISTS public.idx_purchase_vendor_id;
DROP INDEX IF EXISTS public.idx_locations_location_code;
DROP INDEX IF EXISTS public.idx_journal_entry_reference;
DROP INDEX IF EXISTS public.idx_journal_entry_lines_entry_id;
DROP INDEX IF EXISTS public.idx_journal_entry_lines_debit;
DROP INDEX IF EXISTS public.idx_journal_entry_lines_credit;
DROP INDEX IF EXISTS public.idx_journal_entry_line_debit;
DROP INDEX IF EXISTS public.idx_journal_entry_line_credit;
DROP INDEX IF EXISTS public.idx_journal_entry_date;
DROP INDEX IF EXISTS public.idx_journal_entries_reference;
DROP INDEX IF EXISTS public.idx_journal_entries_date;
DROP INDEX IF EXISTS public.idx_inventory_transaction_item_id;
DROP INDEX IF EXISTS public.idx_inventory_items_item_code;
DROP INDEX IF EXISTS public.idx_inventory_item_category_id;
DROP INDEX IF EXISTS public.idx_food_order_status;
DROP INDEX IF EXISTS public.idx_food_order_room_id;
DROP INDEX IF EXISTS public.idx_food_order_billing_status;
DROP INDEX IF EXISTS public.idx_expense_employee_id;
DROP INDEX IF EXISTS public.idx_expense_date;
DROP INDEX IF EXISTS public.idx_checkouts_invoice_number;
DROP INDEX IF EXISTS public.idx_checkout_verifications_checkout_id;
DROP INDEX IF EXISTS public.idx_checkout_room_number;
DROP INDEX IF EXISTS public.idx_checkout_payments_checkout_id;
DROP INDEX IF EXISTS public.idx_checkout_package_booking_id;
DROP INDEX IF EXISTS public.idx_checkout_date;
DROP INDEX IF EXISTS public.idx_checkout_booking_id;
DROP INDEX IF EXISTS public.idx_booking_status;
DROP INDEX IF EXISTS public.idx_booking_check_out;
DROP INDEX IF EXISTS public.idx_booking_check_in;
DROP INDEX IF EXISTS public.idx_account_ledgers_group_id;
ALTER TABLE IF EXISTS ONLY public.working_logs DROP CONSTRAINT IF EXISTS working_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_wo_number_key;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_pkey;
ALTER TABLE IF EXISTS ONLY public.work_order_parts DROP CONSTRAINT IF EXISTS work_order_parts_pkey;
ALTER TABLE IF EXISTS ONLY public.work_order_part_issues DROP CONSTRAINT IF EXISTS work_order_part_issues_pkey;
ALTER TABLE IF EXISTS ONLY public.waste_logs DROP CONSTRAINT IF EXISTS waste_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.waste_logs DROP CONSTRAINT IF EXISTS waste_logs_log_number_key;
ALTER TABLE IF EXISTS ONLY public.wastage_logs DROP CONSTRAINT IF EXISTS wastage_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.vouchers DROP CONSTRAINT IF EXISTS vouchers_pkey;
ALTER TABLE IF EXISTS ONLY public.vouchers DROP CONSTRAINT IF EXISTS vouchers_code_key;
ALTER TABLE IF EXISTS ONLY public.vendors DROP CONSTRAINT IF EXISTS vendors_pkey;
ALTER TABLE IF EXISTS ONLY public.vendors DROP CONSTRAINT IF EXISTS vendors_code_key;
ALTER TABLE IF EXISTS ONLY public.vendor_performance DROP CONSTRAINT IF EXISTS vendor_performance_pkey;
ALTER TABLE IF EXISTS ONLY public.vendor_items DROP CONSTRAINT IF EXISTS vendor_items_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.uom_conversions DROP CONSTRAINT IF EXISTS uom_conversions_pkey;
ALTER TABLE IF EXISTS ONLY public.units_of_measurement DROP CONSTRAINT IF EXISTS units_of_measurement_pkey;
ALTER TABLE IF EXISTS ONLY public.units_of_measurement DROP CONSTRAINT IF EXISTS units_of_measurement_name_key;
ALTER TABLE IF EXISTS ONLY public.system_settings DROP CONSTRAINT IF EXISTS system_settings_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_usage DROP CONSTRAINT IF EXISTS stock_usage_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_requisitions DROP CONSTRAINT IF EXISTS stock_requisitions_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_requisition_details DROP CONSTRAINT IF EXISTS stock_requisition_details_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_movements DROP CONSTRAINT IF EXISTS stock_movements_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_levels DROP CONSTRAINT IF EXISTS stock_levels_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_issues DROP CONSTRAINT IF EXISTS stock_issues_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_issue_details DROP CONSTRAINT IF EXISTS stock_issue_details_pkey;
ALTER TABLE IF EXISTS ONLY public.signature_experiences DROP CONSTRAINT IF EXISTS signature_experiences_pkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_pkey;
ALTER TABLE IF EXISTS ONLY public.service_requests DROP CONSTRAINT IF EXISTS service_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.service_inventory_items DROP CONSTRAINT IF EXISTS service_inventory_items_pkey;
ALTER TABLE IF EXISTS ONLY public.service_images DROP CONSTRAINT IF EXISTS service_images_pkey;
ALTER TABLE IF EXISTS ONLY public.security_uniforms DROP CONSTRAINT IF EXISTS security_uniforms_pkey;
ALTER TABLE IF EXISTS ONLY public.security_maintenance DROP CONSTRAINT IF EXISTS security_maintenance_pkey;
ALTER TABLE IF EXISTS ONLY public.security_equipment DROP CONSTRAINT IF EXISTS security_equipment_pkey;
ALTER TABLE IF EXISTS ONLY public.security_equipment DROP CONSTRAINT IF EXISTS security_equipment_asset_id_key;
ALTER TABLE IF EXISTS ONLY public.rooms DROP CONSTRAINT IF EXISTS rooms_pkey;
ALTER TABLE IF EXISTS ONLY public.rooms DROP CONSTRAINT IF EXISTS rooms_number_key;
ALTER TABLE IF EXISTS ONLY public.room_inventory_items DROP CONSTRAINT IF EXISTS room_inventory_items_pkey;
ALTER TABLE IF EXISTS ONLY public.room_inventory_audits DROP CONSTRAINT IF EXISTS room_inventory_audits_pkey;
ALTER TABLE IF EXISTS ONLY public.room_consumable_items DROP CONSTRAINT IF EXISTS room_consumable_items_pkey;
ALTER TABLE IF EXISTS ONLY public.room_consumable_assignments DROP CONSTRAINT IF EXISTS room_consumable_assignments_pkey;
ALTER TABLE IF EXISTS ONLY public.room_assets DROP CONSTRAINT IF EXISTS room_assets_pkey;
ALTER TABLE IF EXISTS ONLY public.room_assets DROP CONSTRAINT IF EXISTS room_assets_asset_id_key;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_name_key;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.restock_alerts DROP CONSTRAINT IF EXISTS restock_alerts_pkey;
ALTER TABLE IF EXISTS ONLY public.resort_info DROP CONSTRAINT IF EXISTS resort_info_pkey;
ALTER TABLE IF EXISTS ONLY public.recipes DROP CONSTRAINT IF EXISTS recipes_pkey;
ALTER TABLE IF EXISTS ONLY public.recipe_ingredients DROP CONSTRAINT IF EXISTS recipe_ingredients_pkey;
ALTER TABLE IF EXISTS ONLY public.purchase_orders DROP CONSTRAINT IF EXISTS purchase_orders_po_number_key;
ALTER TABLE IF EXISTS ONLY public.purchase_orders DROP CONSTRAINT IF EXISTS purchase_orders_pkey;
ALTER TABLE IF EXISTS ONLY public.purchase_masters DROP CONSTRAINT IF EXISTS purchase_masters_pkey;
ALTER TABLE IF EXISTS ONLY public.purchase_entry_items DROP CONSTRAINT IF EXISTS purchase_entry_items_pkey;
ALTER TABLE IF EXISTS ONLY public.purchase_entries DROP CONSTRAINT IF EXISTS purchase_entries_pkey;
ALTER TABLE IF EXISTS ONLY public.purchase_entries DROP CONSTRAINT IF EXISTS purchase_entries_entry_number_key;
ALTER TABLE IF EXISTS ONLY public.purchase_details DROP CONSTRAINT IF EXISTS purchase_details_pkey;
ALTER TABLE IF EXISTS ONLY public.po_items DROP CONSTRAINT IF EXISTS po_items_pkey;
ALTER TABLE IF EXISTS ONLY public.plan_weddings DROP CONSTRAINT IF EXISTS plan_weddings_pkey;
ALTER TABLE IF EXISTS ONLY public.perishable_batches DROP CONSTRAINT IF EXISTS perishable_batches_pkey;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_pkey;
ALTER TABLE IF EXISTS ONLY public.packages DROP CONSTRAINT IF EXISTS packages_pkey;
ALTER TABLE IF EXISTS ONLY public.package_images DROP CONSTRAINT IF EXISTS package_images_pkey;
ALTER TABLE IF EXISTS ONLY public.package_bookings DROP CONSTRAINT IF EXISTS package_bookings_pkey;
ALTER TABLE IF EXISTS ONLY public.package_booking_rooms DROP CONSTRAINT IF EXISTS package_booking_rooms_pkey;
ALTER TABLE IF EXISTS ONLY public.outlets DROP CONSTRAINT IF EXISTS outlets_pkey;
ALTER TABLE IF EXISTS ONLY public.outlets DROP CONSTRAINT IF EXISTS outlets_name_key;
ALTER TABLE IF EXISTS ONLY public.outlets DROP CONSTRAINT IF EXISTS outlets_code_key;
ALTER TABLE IF EXISTS ONLY public.outlet_stocks DROP CONSTRAINT IF EXISTS outlet_stocks_pkey;
ALTER TABLE IF EXISTS ONLY public.office_requisitions DROP CONSTRAINT IF EXISTS office_requisitions_req_number_key;
ALTER TABLE IF EXISTS ONLY public.office_requisitions DROP CONSTRAINT IF EXISTS office_requisitions_pkey;
ALTER TABLE IF EXISTS ONLY public.office_inventory_items DROP CONSTRAINT IF EXISTS office_inventory_items_pkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.nearby_attractions DROP CONSTRAINT IF EXISTS nearby_attractions_pkey;
ALTER TABLE IF EXISTS ONLY public.nearby_attraction_banners DROP CONSTRAINT IF EXISTS nearby_attraction_banners_pkey;
ALTER TABLE IF EXISTS ONLY public.maintenance_tickets DROP CONSTRAINT IF EXISTS maintenance_tickets_pkey;
ALTER TABLE IF EXISTS ONLY public.lost_found DROP CONSTRAINT IF EXISTS lost_found_pkey;
ALTER TABLE IF EXISTS ONLY public.locations DROP CONSTRAINT IF EXISTS locations_pkey;
ALTER TABLE IF EXISTS ONLY public.locations DROP CONSTRAINT IF EXISTS locations_location_code_key;
ALTER TABLE IF EXISTS ONLY public.locations DROP CONSTRAINT IF EXISTS locations_code_key;
ALTER TABLE IF EXISTS ONLY public.location_stocks DROP CONSTRAINT IF EXISTS location_stocks_pkey;
ALTER TABLE IF EXISTS ONLY public.linen_wash_logs DROP CONSTRAINT IF EXISTS linen_wash_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.linen_stocks DROP CONSTRAINT IF EXISTS linen_stocks_pkey;
ALTER TABLE IF EXISTS ONLY public.linen_movements DROP CONSTRAINT IF EXISTS linen_movements_pkey;
ALTER TABLE IF EXISTS ONLY public.linen_items DROP CONSTRAINT IF EXISTS linen_items_rfid_tag_key;
ALTER TABLE IF EXISTS ONLY public.linen_items DROP CONSTRAINT IF EXISTS linen_items_pkey;
ALTER TABLE IF EXISTS ONLY public.linen_items DROP CONSTRAINT IF EXISTS linen_items_barcode_key;
ALTER TABLE IF EXISTS ONLY public.legal_documents DROP CONSTRAINT IF EXISTS legal_documents_pkey;
ALTER TABLE IF EXISTS ONLY public.leaves DROP CONSTRAINT IF EXISTS leaves_pkey;
ALTER TABLE IF EXISTS ONLY public.laundry_services DROP CONSTRAINT IF EXISTS laundry_services_pkey;
ALTER TABLE IF EXISTS ONLY public.key_movements DROP CONSTRAINT IF EXISTS key_movements_pkey;
ALTER TABLE IF EXISTS ONLY public.key_management DROP CONSTRAINT IF EXISTS key_management_pkey;
ALTER TABLE IF EXISTS ONLY public.key_management DROP CONSTRAINT IF EXISTS key_management_key_number_key;
ALTER TABLE IF EXISTS ONLY public.journal_entry_lines DROP CONSTRAINT IF EXISTS journal_entry_lines_pkey;
ALTER TABLE IF EXISTS ONLY public.journal_entries DROP CONSTRAINT IF EXISTS journal_entries_pkey;
ALTER TABLE IF EXISTS ONLY public.journal_entries DROP CONSTRAINT IF EXISTS journal_entries_entry_number_key;
ALTER TABLE IF EXISTS ONLY public.inventory_transactions DROP CONSTRAINT IF EXISTS inventory_transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.inventory_items DROP CONSTRAINT IF EXISTS inventory_items_sku_key;
ALTER TABLE IF EXISTS ONLY public.inventory_items DROP CONSTRAINT IF EXISTS inventory_items_pkey;
ALTER TABLE IF EXISTS ONLY public.inventory_expenses DROP CONSTRAINT IF EXISTS inventory_expenses_pkey;
ALTER TABLE IF EXISTS ONLY public.inventory_categories DROP CONSTRAINT IF EXISTS inventory_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.inventory_categories DROP CONSTRAINT IF EXISTS inventory_categories_name_key;
ALTER TABLE IF EXISTS ONLY public.indents DROP CONSTRAINT IF EXISTS indents_pkey;
ALTER TABLE IF EXISTS ONLY public.indents DROP CONSTRAINT IF EXISTS indents_indent_number_key;
ALTER TABLE IF EXISTS ONLY public.indent_items DROP CONSTRAINT IF EXISTS indent_items_pkey;
ALTER TABLE IF EXISTS ONLY public.header_banner DROP CONSTRAINT IF EXISTS header_banner_pkey;
ALTER TABLE IF EXISTS ONLY public.guest_suggestions DROP CONSTRAINT IF EXISTS guest_suggestions_pkey;
ALTER TABLE IF EXISTS ONLY public.grn_items DROP CONSTRAINT IF EXISTS grn_items_pkey;
ALTER TABLE IF EXISTS ONLY public.goods_received_notes DROP CONSTRAINT IF EXISTS goods_received_notes_pkey;
ALTER TABLE IF EXISTS ONLY public.goods_received_notes DROP CONSTRAINT IF EXISTS goods_received_notes_grn_number_key;
ALTER TABLE IF EXISTS ONLY public.gallery DROP CONSTRAINT IF EXISTS gallery_pkey;
ALTER TABLE IF EXISTS ONLY public.food_orders DROP CONSTRAINT IF EXISTS food_orders_pkey;
ALTER TABLE IF EXISTS ONLY public.food_order_items DROP CONSTRAINT IF EXISTS food_order_items_pkey;
ALTER TABLE IF EXISTS ONLY public.food_items DROP CONSTRAINT IF EXISTS food_items_pkey;
ALTER TABLE IF EXISTS ONLY public.food_item_images DROP CONSTRAINT IF EXISTS food_item_images_pkey;
ALTER TABLE IF EXISTS ONLY public.food_categories DROP CONSTRAINT IF EXISTS food_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.first_aid_kits DROP CONSTRAINT IF EXISTS first_aid_kits_pkey;
ALTER TABLE IF EXISTS ONLY public.first_aid_kits DROP CONSTRAINT IF EXISTS first_aid_kits_kit_number_key;
ALTER TABLE IF EXISTS ONLY public.first_aid_kit_items DROP CONSTRAINT IF EXISTS first_aid_kit_items_pkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_maintenance DROP CONSTRAINT IF EXISTS fire_safety_maintenance_pkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_inspections DROP CONSTRAINT IF EXISTS fire_safety_inspections_pkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_incidents DROP CONSTRAINT IF EXISTS fire_safety_incidents_pkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_equipment DROP CONSTRAINT IF EXISTS fire_safety_equipment_pkey;
ALTER TABLE IF EXISTS ONLY public.fire_safety_equipment DROP CONSTRAINT IF EXISTS fire_safety_equipment_asset_id_key;
ALTER TABLE IF EXISTS ONLY public.expiry_alerts DROP CONSTRAINT IF EXISTS expiry_alerts_pkey;
ALTER TABLE IF EXISTS ONLY public.expenses DROP CONSTRAINT IF EXISTS expenses_pkey;
ALTER TABLE IF EXISTS ONLY public.eod_audits DROP CONSTRAINT IF EXISTS eod_audits_pkey;
ALTER TABLE IF EXISTS ONLY public.eod_audit_items DROP CONSTRAINT IF EXISTS eod_audit_items_pkey;
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS employees_user_id_key;
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS employees_pkey;
ALTER TABLE IF EXISTS ONLY public.employee_inventory_assignments DROP CONSTRAINT IF EXISTS employee_inventory_assignments_pkey;
ALTER TABLE IF EXISTS ONLY public.damage_reports DROP CONSTRAINT IF EXISTS damage_reports_pkey;
ALTER TABLE IF EXISTS ONLY public.cost_centers DROP CONSTRAINT IF EXISTS cost_centers_pkey;
ALTER TABLE IF EXISTS ONLY public.cost_centers DROP CONSTRAINT IF EXISTS cost_centers_name_key;
ALTER TABLE IF EXISTS ONLY public.cost_centers DROP CONSTRAINT IF EXISTS cost_centers_code_key;
ALTER TABLE IF EXISTS ONLY public.consumable_usage DROP CONSTRAINT IF EXISTS consumable_usage_pkey;
ALTER TABLE IF EXISTS ONLY public.checkouts DROP CONSTRAINT IF EXISTS checkouts_pkey;
ALTER TABLE IF EXISTS ONLY public.checkouts DROP CONSTRAINT IF EXISTS checkouts_package_booking_id_key;
ALTER TABLE IF EXISTS ONLY public.checkouts DROP CONSTRAINT IF EXISTS checkouts_booking_id_key;
ALTER TABLE IF EXISTS ONLY public.checkout_verifications DROP CONSTRAINT IF EXISTS checkout_verifications_pkey;
ALTER TABLE IF EXISTS ONLY public.checkout_requests DROP CONSTRAINT IF EXISTS checkout_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.checkout_payments DROP CONSTRAINT IF EXISTS checkout_payments_pkey;
ALTER TABLE IF EXISTS ONLY public.checklists DROP CONSTRAINT IF EXISTS checklists_pkey;
ALTER TABLE IF EXISTS ONLY public.checklist_responses DROP CONSTRAINT IF EXISTS checklist_responses_pkey;
ALTER TABLE IF EXISTS ONLY public.checklist_items DROP CONSTRAINT IF EXISTS checklist_items_pkey;
ALTER TABLE IF EXISTS ONLY public.checklist_executions DROP CONSTRAINT IF EXISTS checklist_executions_pkey;
ALTER TABLE IF EXISTS ONLY public.check_availability DROP CONSTRAINT IF EXISTS check_availability_pkey;
ALTER TABLE IF EXISTS ONLY public.bookings DROP CONSTRAINT IF EXISTS bookings_pkey;
ALTER TABLE IF EXISTS ONLY public.booking_rooms DROP CONSTRAINT IF EXISTS booking_rooms_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_discrepancies DROP CONSTRAINT IF EXISTS audit_discrepancies_pkey;
ALTER TABLE IF EXISTS ONLY public.attendances DROP CONSTRAINT IF EXISTS attendances_pkey;
ALTER TABLE IF EXISTS ONLY public.assigned_services DROP CONSTRAINT IF EXISTS assigned_services_pkey;
ALTER TABLE IF EXISTS ONLY public.asset_registry DROP CONSTRAINT IF EXISTS asset_registry_pkey;
ALTER TABLE IF EXISTS ONLY public.asset_mappings DROP CONSTRAINT IF EXISTS asset_mappings_pkey;
ALTER TABLE IF EXISTS ONLY public.asset_maintenance DROP CONSTRAINT IF EXISTS asset_maintenance_pkey;
ALTER TABLE IF EXISTS ONLY public.asset_inspections DROP CONSTRAINT IF EXISTS asset_inspections_pkey;
ALTER TABLE IF EXISTS ONLY public.approval_requests DROP CONSTRAINT IF EXISTS approval_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.approval_matrices DROP CONSTRAINT IF EXISTS approval_matrices_pkey;
ALTER TABLE IF EXISTS ONLY public.alembic_version DROP CONSTRAINT IF EXISTS alembic_version_pkc;
ALTER TABLE IF EXISTS ONLY public.account_ledgers DROP CONSTRAINT IF EXISTS account_ledgers_pkey;
ALTER TABLE IF EXISTS ONLY public.account_ledgers DROP CONSTRAINT IF EXISTS account_ledgers_code_key;
ALTER TABLE IF EXISTS ONLY public.account_groups DROP CONSTRAINT IF EXISTS account_groups_pkey;
ALTER TABLE IF EXISTS ONLY public.account_groups DROP CONSTRAINT IF EXISTS account_groups_name_key;
ALTER TABLE IF EXISTS public.working_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.work_orders ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.work_order_parts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.work_order_part_issues ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.waste_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.wastage_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.vouchers ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.vendors ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.vendor_performance ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.vendor_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.uom_conversions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.units_of_measurement ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.system_settings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stock_usage ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stock_requisitions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stock_requisition_details ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stock_movements ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stock_levels ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stock_issues ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stock_issue_details ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.signature_experiences ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.services ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.service_requests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.service_images ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.security_uniforms ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.security_maintenance ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.security_equipment ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.rooms ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.room_inventory_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.room_inventory_audits ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.room_consumable_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.room_consumable_assignments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.room_assets ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.reviews ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.restock_alerts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.resort_info ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.recipes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.recipe_ingredients ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.purchase_orders ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.purchase_masters ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.purchase_entry_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.purchase_entries ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.purchase_details ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.po_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.plan_weddings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.perishable_batches ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.payments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.packages ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.package_images ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.package_bookings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.package_booking_rooms ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.outlets ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.outlet_stocks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.office_requisitions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.office_inventory_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.notifications ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.nearby_attractions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.nearby_attraction_banners ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.maintenance_tickets ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.lost_found ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.locations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.location_stocks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.linen_wash_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.linen_stocks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.linen_movements ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.linen_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.legal_documents ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.leaves ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.laundry_services ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.key_movements ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.key_management ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.journal_entry_lines ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.journal_entries ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.inventory_transactions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.inventory_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.inventory_expenses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.inventory_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.indents ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.indent_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.header_banner ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.guest_suggestions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.grn_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.goods_received_notes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.gallery ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.food_orders ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.food_order_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.food_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.food_item_images ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.food_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.first_aid_kits ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.first_aid_kit_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.fire_safety_maintenance ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.fire_safety_inspections ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.fire_safety_incidents ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.fire_safety_equipment ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.expiry_alerts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.expenses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.eod_audits ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.eod_audit_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.employees ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.employee_inventory_assignments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.damage_reports ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cost_centers ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.consumable_usage ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.checkouts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.checkout_verifications ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.checkout_requests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.checkout_payments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.checklists ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.checklist_responses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.checklist_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.checklist_executions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.check_availability ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.bookings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.booking_rooms ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.audit_discrepancies ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.attendances ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.assigned_services ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.asset_registry ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.asset_mappings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.asset_maintenance ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.asset_inspections ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.approval_requests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.approval_matrices ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.account_ledgers ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.account_groups ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.working_logs_id_seq;
DROP TABLE IF EXISTS public.working_logs;
DROP SEQUENCE IF EXISTS public.work_orders_id_seq;
DROP TABLE IF EXISTS public.work_orders;
DROP SEQUENCE IF EXISTS public.work_order_parts_id_seq;
DROP TABLE IF EXISTS public.work_order_parts;
DROP SEQUENCE IF EXISTS public.work_order_part_issues_id_seq;
DROP TABLE IF EXISTS public.work_order_part_issues;
DROP SEQUENCE IF EXISTS public.waste_logs_id_seq;
DROP TABLE IF EXISTS public.waste_logs;
DROP SEQUENCE IF EXISTS public.wastage_logs_id_seq;
DROP TABLE IF EXISTS public.wastage_logs;
DROP SEQUENCE IF EXISTS public.vouchers_id_seq;
DROP TABLE IF EXISTS public.vouchers;
DROP SEQUENCE IF EXISTS public.vendors_id_seq;
DROP TABLE IF EXISTS public.vendors;
DROP SEQUENCE IF EXISTS public.vendor_performance_id_seq;
DROP TABLE IF EXISTS public.vendor_performance;
DROP SEQUENCE IF EXISTS public.vendor_items_id_seq;
DROP TABLE IF EXISTS public.vendor_items;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.uom_conversions_id_seq;
DROP TABLE IF EXISTS public.uom_conversions;
DROP SEQUENCE IF EXISTS public.units_of_measurement_id_seq;
DROP TABLE IF EXISTS public.units_of_measurement;
DROP SEQUENCE IF EXISTS public.system_settings_id_seq;
DROP TABLE IF EXISTS public.system_settings;
DROP SEQUENCE IF EXISTS public.stock_usage_id_seq;
DROP TABLE IF EXISTS public.stock_usage;
DROP SEQUENCE IF EXISTS public.stock_requisitions_id_seq;
DROP TABLE IF EXISTS public.stock_requisitions;
DROP SEQUENCE IF EXISTS public.stock_requisition_details_id_seq;
DROP TABLE IF EXISTS public.stock_requisition_details;
DROP SEQUENCE IF EXISTS public.stock_movements_id_seq;
DROP TABLE IF EXISTS public.stock_movements;
DROP SEQUENCE IF EXISTS public.stock_levels_id_seq;
DROP TABLE IF EXISTS public.stock_levels;
DROP SEQUENCE IF EXISTS public.stock_issues_id_seq;
DROP TABLE IF EXISTS public.stock_issues;
DROP SEQUENCE IF EXISTS public.stock_issue_details_id_seq;
DROP TABLE IF EXISTS public.stock_issue_details;
DROP SEQUENCE IF EXISTS public.signature_experiences_id_seq;
DROP TABLE IF EXISTS public.signature_experiences;
DROP SEQUENCE IF EXISTS public.services_id_seq;
DROP TABLE IF EXISTS public.services;
DROP SEQUENCE IF EXISTS public.service_requests_id_seq;
DROP TABLE IF EXISTS public.service_requests;
DROP TABLE IF EXISTS public.service_inventory_items;
DROP SEQUENCE IF EXISTS public.service_images_id_seq;
DROP TABLE IF EXISTS public.service_images;
DROP SEQUENCE IF EXISTS public.security_uniforms_id_seq;
DROP TABLE IF EXISTS public.security_uniforms;
DROP SEQUENCE IF EXISTS public.security_maintenance_id_seq;
DROP TABLE IF EXISTS public.security_maintenance;
DROP SEQUENCE IF EXISTS public.security_equipment_id_seq;
DROP TABLE IF EXISTS public.security_equipment;
DROP SEQUENCE IF EXISTS public.rooms_id_seq;
DROP TABLE IF EXISTS public.rooms;
DROP SEQUENCE IF EXISTS public.room_inventory_items_id_seq;
DROP TABLE IF EXISTS public.room_inventory_items;
DROP SEQUENCE IF EXISTS public.room_inventory_audits_id_seq;
DROP TABLE IF EXISTS public.room_inventory_audits;
DROP SEQUENCE IF EXISTS public.room_consumable_items_id_seq;
DROP TABLE IF EXISTS public.room_consumable_items;
DROP SEQUENCE IF EXISTS public.room_consumable_assignments_id_seq;
DROP TABLE IF EXISTS public.room_consumable_assignments;
DROP SEQUENCE IF EXISTS public.room_assets_id_seq;
DROP TABLE IF EXISTS public.room_assets;
DROP SEQUENCE IF EXISTS public.roles_id_seq;
DROP TABLE IF EXISTS public.roles;
DROP SEQUENCE IF EXISTS public.reviews_id_seq;
DROP TABLE IF EXISTS public.reviews;
DROP SEQUENCE IF EXISTS public.restock_alerts_id_seq;
DROP TABLE IF EXISTS public.restock_alerts;
DROP SEQUENCE IF EXISTS public.resort_info_id_seq;
DROP TABLE IF EXISTS public.resort_info;
DROP SEQUENCE IF EXISTS public.recipes_id_seq;
DROP TABLE IF EXISTS public.recipes;
DROP SEQUENCE IF EXISTS public.recipe_ingredients_id_seq;
DROP TABLE IF EXISTS public.recipe_ingredients;
DROP SEQUENCE IF EXISTS public.purchase_orders_id_seq;
DROP TABLE IF EXISTS public.purchase_orders;
DROP SEQUENCE IF EXISTS public.purchase_masters_id_seq;
DROP TABLE IF EXISTS public.purchase_masters;
DROP SEQUENCE IF EXISTS public.purchase_entry_items_id_seq;
DROP TABLE IF EXISTS public.purchase_entry_items;
DROP SEQUENCE IF EXISTS public.purchase_entries_id_seq;
DROP TABLE IF EXISTS public.purchase_entries;
DROP SEQUENCE IF EXISTS public.purchase_details_id_seq;
DROP TABLE IF EXISTS public.purchase_details;
DROP SEQUENCE IF EXISTS public.po_items_id_seq;
DROP TABLE IF EXISTS public.po_items;
DROP SEQUENCE IF EXISTS public.plan_weddings_id_seq;
DROP TABLE IF EXISTS public.plan_weddings;
DROP SEQUENCE IF EXISTS public.perishable_batches_id_seq;
DROP TABLE IF EXISTS public.perishable_batches;
DROP SEQUENCE IF EXISTS public.payments_id_seq;
DROP TABLE IF EXISTS public.payments;
DROP SEQUENCE IF EXISTS public.packages_id_seq;
DROP TABLE IF EXISTS public.packages;
DROP SEQUENCE IF EXISTS public.package_images_id_seq;
DROP TABLE IF EXISTS public.package_images;
DROP SEQUENCE IF EXISTS public.package_bookings_id_seq;
DROP TABLE IF EXISTS public.package_bookings;
DROP SEQUENCE IF EXISTS public.package_booking_rooms_id_seq;
DROP TABLE IF EXISTS public.package_booking_rooms;
DROP SEQUENCE IF EXISTS public.outlets_id_seq;
DROP TABLE IF EXISTS public.outlets;
DROP SEQUENCE IF EXISTS public.outlet_stocks_id_seq;
DROP TABLE IF EXISTS public.outlet_stocks;
DROP SEQUENCE IF EXISTS public.office_requisitions_id_seq;
DROP TABLE IF EXISTS public.office_requisitions;
DROP SEQUENCE IF EXISTS public.office_inventory_items_id_seq;
DROP TABLE IF EXISTS public.office_inventory_items;
DROP SEQUENCE IF EXISTS public.notifications_id_seq;
DROP TABLE IF EXISTS public.notifications;
DROP SEQUENCE IF EXISTS public.nearby_attractions_id_seq;
DROP TABLE IF EXISTS public.nearby_attractions;
DROP SEQUENCE IF EXISTS public.nearby_attraction_banners_id_seq;
DROP TABLE IF EXISTS public.nearby_attraction_banners;
DROP SEQUENCE IF EXISTS public.maintenance_tickets_id_seq;
DROP TABLE IF EXISTS public.maintenance_tickets;
DROP SEQUENCE IF EXISTS public.lost_found_id_seq;
DROP TABLE IF EXISTS public.lost_found;
DROP SEQUENCE IF EXISTS public.locations_id_seq;
DROP TABLE IF EXISTS public.locations;
DROP SEQUENCE IF EXISTS public.location_stocks_id_seq;
DROP TABLE IF EXISTS public.location_stocks;
DROP SEQUENCE IF EXISTS public.linen_wash_logs_id_seq;
DROP TABLE IF EXISTS public.linen_wash_logs;
DROP SEQUENCE IF EXISTS public.linen_stocks_id_seq;
DROP TABLE IF EXISTS public.linen_stocks;
DROP SEQUENCE IF EXISTS public.linen_movements_id_seq;
DROP TABLE IF EXISTS public.linen_movements;
DROP SEQUENCE IF EXISTS public.linen_items_id_seq;
DROP TABLE IF EXISTS public.linen_items;
DROP SEQUENCE IF EXISTS public.legal_documents_id_seq;
DROP TABLE IF EXISTS public.legal_documents;
DROP SEQUENCE IF EXISTS public.leaves_id_seq;
DROP TABLE IF EXISTS public.leaves;
DROP SEQUENCE IF EXISTS public.laundry_services_id_seq;
DROP TABLE IF EXISTS public.laundry_services;
DROP SEQUENCE IF EXISTS public.key_movements_id_seq;
DROP TABLE IF EXISTS public.key_movements;
DROP SEQUENCE IF EXISTS public.key_management_id_seq;
DROP TABLE IF EXISTS public.key_management;
DROP SEQUENCE IF EXISTS public.journal_entry_lines_id_seq;
DROP TABLE IF EXISTS public.journal_entry_lines;
DROP SEQUENCE IF EXISTS public.journal_entries_id_seq;
DROP TABLE IF EXISTS public.journal_entries;
DROP SEQUENCE IF EXISTS public.inventory_transactions_id_seq;
DROP TABLE IF EXISTS public.inventory_transactions;
DROP SEQUENCE IF EXISTS public.inventory_items_id_seq;
DROP TABLE IF EXISTS public.inventory_items;
DROP SEQUENCE IF EXISTS public.inventory_expenses_id_seq;
DROP TABLE IF EXISTS public.inventory_expenses;
DROP SEQUENCE IF EXISTS public.inventory_categories_id_seq;
DROP TABLE IF EXISTS public.inventory_categories;
DROP SEQUENCE IF EXISTS public.indents_id_seq;
DROP TABLE IF EXISTS public.indents;
DROP SEQUENCE IF EXISTS public.indent_items_id_seq;
DROP TABLE IF EXISTS public.indent_items;
DROP SEQUENCE IF EXISTS public.header_banner_id_seq;
DROP TABLE IF EXISTS public.header_banner;
DROP SEQUENCE IF EXISTS public.guest_suggestions_id_seq;
DROP TABLE IF EXISTS public.guest_suggestions;
DROP SEQUENCE IF EXISTS public.grn_items_id_seq;
DROP TABLE IF EXISTS public.grn_items;
DROP SEQUENCE IF EXISTS public.goods_received_notes_id_seq;
DROP TABLE IF EXISTS public.goods_received_notes;
DROP SEQUENCE IF EXISTS public.gallery_id_seq;
DROP TABLE IF EXISTS public.gallery;
DROP SEQUENCE IF EXISTS public.food_orders_id_seq;
DROP TABLE IF EXISTS public.food_orders;
DROP SEQUENCE IF EXISTS public.food_order_items_id_seq;
DROP TABLE IF EXISTS public.food_order_items;
DROP SEQUENCE IF EXISTS public.food_items_id_seq;
DROP TABLE IF EXISTS public.food_items;
DROP SEQUENCE IF EXISTS public.food_item_images_id_seq;
DROP TABLE IF EXISTS public.food_item_images;
DROP SEQUENCE IF EXISTS public.food_categories_id_seq;
DROP TABLE IF EXISTS public.food_categories;
DROP SEQUENCE IF EXISTS public.first_aid_kits_id_seq;
DROP TABLE IF EXISTS public.first_aid_kits;
DROP SEQUENCE IF EXISTS public.first_aid_kit_items_id_seq;
DROP TABLE IF EXISTS public.first_aid_kit_items;
DROP SEQUENCE IF EXISTS public.fire_safety_maintenance_id_seq;
DROP TABLE IF EXISTS public.fire_safety_maintenance;
DROP SEQUENCE IF EXISTS public.fire_safety_inspections_id_seq;
DROP TABLE IF EXISTS public.fire_safety_inspections;
DROP SEQUENCE IF EXISTS public.fire_safety_incidents_id_seq;
DROP TABLE IF EXISTS public.fire_safety_incidents;
DROP SEQUENCE IF EXISTS public.fire_safety_equipment_id_seq;
DROP TABLE IF EXISTS public.fire_safety_equipment;
DROP SEQUENCE IF EXISTS public.expiry_alerts_id_seq;
DROP TABLE IF EXISTS public.expiry_alerts;
DROP SEQUENCE IF EXISTS public.expenses_id_seq;
DROP TABLE IF EXISTS public.expenses;
DROP SEQUENCE IF EXISTS public.eod_audits_id_seq;
DROP TABLE IF EXISTS public.eod_audits;
DROP SEQUENCE IF EXISTS public.eod_audit_items_id_seq;
DROP TABLE IF EXISTS public.eod_audit_items;
DROP SEQUENCE IF EXISTS public.employees_id_seq;
DROP TABLE IF EXISTS public.employees;
DROP SEQUENCE IF EXISTS public.employee_inventory_assignments_id_seq;
DROP TABLE IF EXISTS public.employee_inventory_assignments;
DROP SEQUENCE IF EXISTS public.damage_reports_id_seq;
DROP TABLE IF EXISTS public.damage_reports;
DROP SEQUENCE IF EXISTS public.cost_centers_id_seq;
DROP TABLE IF EXISTS public.cost_centers;
DROP SEQUENCE IF EXISTS public.consumable_usage_id_seq;
DROP TABLE IF EXISTS public.consumable_usage;
DROP SEQUENCE IF EXISTS public.checkouts_id_seq;
DROP TABLE IF EXISTS public.checkouts;
DROP SEQUENCE IF EXISTS public.checkout_verifications_id_seq;
DROP TABLE IF EXISTS public.checkout_verifications;
DROP SEQUENCE IF EXISTS public.checkout_requests_id_seq;
DROP TABLE IF EXISTS public.checkout_requests;
DROP SEQUENCE IF EXISTS public.checkout_payments_id_seq;
DROP TABLE IF EXISTS public.checkout_payments;
DROP SEQUENCE IF EXISTS public.checklists_id_seq;
DROP TABLE IF EXISTS public.checklists;
DROP SEQUENCE IF EXISTS public.checklist_responses_id_seq;
DROP TABLE IF EXISTS public.checklist_responses;
DROP SEQUENCE IF EXISTS public.checklist_items_id_seq;
DROP TABLE IF EXISTS public.checklist_items;
DROP SEQUENCE IF EXISTS public.checklist_executions_id_seq;
DROP TABLE IF EXISTS public.checklist_executions;
DROP SEQUENCE IF EXISTS public.check_availability_id_seq;
DROP TABLE IF EXISTS public.check_availability;
DROP SEQUENCE IF EXISTS public.bookings_id_seq;
DROP TABLE IF EXISTS public.bookings;
DROP SEQUENCE IF EXISTS public.booking_rooms_id_seq;
DROP TABLE IF EXISTS public.booking_rooms;
DROP SEQUENCE IF EXISTS public.audit_discrepancies_id_seq;
DROP TABLE IF EXISTS public.audit_discrepancies;
DROP SEQUENCE IF EXISTS public.attendances_id_seq;
DROP TABLE IF EXISTS public.attendances;
DROP SEQUENCE IF EXISTS public.assigned_services_id_seq;
DROP TABLE IF EXISTS public.assigned_services;
DROP SEQUENCE IF EXISTS public.asset_registry_id_seq;
DROP TABLE IF EXISTS public.asset_registry;
DROP SEQUENCE IF EXISTS public.asset_mappings_id_seq;
DROP TABLE IF EXISTS public.asset_mappings;
DROP SEQUENCE IF EXISTS public.asset_maintenance_id_seq;
DROP TABLE IF EXISTS public.asset_maintenance;
DROP SEQUENCE IF EXISTS public.asset_inspections_id_seq;
DROP TABLE IF EXISTS public.asset_inspections;
DROP SEQUENCE IF EXISTS public.approval_requests_id_seq;
DROP TABLE IF EXISTS public.approval_requests;
DROP SEQUENCE IF EXISTS public.approval_matrices_id_seq;
DROP TABLE IF EXISTS public.approval_matrices;
DROP TABLE IF EXISTS public.alembic_version;
DROP SEQUENCE IF EXISTS public.account_ledgers_id_seq;
DROP TABLE IF EXISTS public.account_ledgers;
DROP SEQUENCE IF EXISTS public.account_groups_id_seq;
DROP TABLE IF EXISTS public.account_groups;
DROP FUNCTION IF EXISTS public.set_uom_from_unit();
DROP FUNCTION IF EXISTS public.set_item_id_from_inventory_item_id();
DROP TYPE IF EXISTS public.workorderstatus;
DROP TYPE IF EXISTS public.stockstate;
DROP TYPE IF EXISTS public.servicestatus;
DROP TYPE IF EXISTS public.postatus;
DROP TYPE IF EXISTS public.notificationtype;
DROP TYPE IF EXISTS public.locationtype;
DROP TYPE IF EXISTS public.indentstatus;
DROP TYPE IF EXISTS public.grnstatus;
DROP TYPE IF EXISTS public.categorytype;
DROP TYPE IF EXISTS public.accounttype;
--
-- Name: accounttype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.accounttype AS ENUM (
    'REVENUE',
    'EXPENSE',
    'ASSET',
    'LIABILITY',
    'TAX'
);


--
-- Name: categorytype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.categorytype AS ENUM (
    'RESTAURANT',
    'FACILITY',
    'CUSTOMER_CONSUMABLES',
    'OFFICE',
    'HOTEL_ROOM',
    'FIRE_SAFETY',
    'SECURITY'
);


--
-- Name: grnstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.grnstatus AS ENUM (
    'PENDING',
    'VERIFIED',
    'REJECTED'
);


--
-- Name: indentstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.indentstatus AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'FULFILLED'
);


--
-- Name: locationtype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.locationtype AS ENUM (
    'CENTRAL_WAREHOUSE',
    'BRANCH_STORE',
    'SUB_STORE',
    'GUEST_ROOM',
    'WAREHOUSE',
    'DEPARTMENT',
    'PUBLIC_AREA',
    'LAUNDRY'
);


--
-- Name: notificationtype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notificationtype AS ENUM (
    'SERVICE',
    'BOOKING',
    'PACKAGE',
    'INVENTORY',
    'EXPENSE',
    'FOOD_ORDER',
    'SUCCESS',
    'ERROR',
    'INFO'
);


--
-- Name: postatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.postatus AS ENUM (
    'DRAFT',
    'SENT',
    'ACKNOWLEDGED',
    'PARTIALLY_RECEIVED',
    'RECEIVED',
    'CANCELLED'
);


--
-- Name: servicestatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.servicestatus AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'cancelled'
);


--
-- Name: stockstate; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.stockstate AS ENUM (
    'IN_ROOM',
    'IN_CLOSET',
    'IN_LAUNDRY',
    'IN_STORE',
    'DAMAGED',
    'LOST'
);


--
-- Name: workorderstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.workorderstatus AS ENUM (
    'PENDING',
    'ASSIGNED',
    'IN_PROGRESS',
    'WAITING_PARTS',
    'COMPLETED',
    'CANCELLED'
);


--
-- Name: set_item_id_from_inventory_item_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_item_id_from_inventory_item_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                IF NEW.item_id IS NULL AND NEW.inventory_item_id IS NOT NULL THEN
                    NEW.item_id := NEW.inventory_item_id;
                END IF;
                RETURN NEW;
            END;
            $$;


--
-- Name: set_uom_from_unit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_uom_from_unit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                IF NEW.uom IS NULL AND NEW.unit IS NOT NULL THEN
                    NEW.uom := NEW.unit;
                END IF;
                RETURN NEW;
            END;
            $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_groups (
    id integer NOT NULL,
    name character varying NOT NULL,
    account_type public.accounttype NOT NULL,
    description text,
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


--
-- Name: account_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_groups_id_seq OWNED BY public.account_groups.id;


--
-- Name: account_ledgers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_ledgers (
    id integer NOT NULL,
    name character varying NOT NULL,
    code character varying,
    group_id integer NOT NULL,
    module character varying,
    description text,
    opening_balance double precision,
    balance_type character varying NOT NULL,
    is_active boolean NOT NULL,
    tax_type character varying,
    tax_rate double precision,
    bank_name character varying,
    account_number character varying,
    ifsc_code character varying,
    branch_name character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


--
-- Name: account_ledgers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_ledgers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_ledgers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_ledgers_id_seq OWNED BY public.account_ledgers.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: approval_matrices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.approval_matrices (
    id integer NOT NULL,
    department_id integer,
    approval_type character varying NOT NULL,
    min_amount double precision,
    max_amount double precision,
    level_1_approver_role character varying,
    level_2_approver_role character varying,
    level_3_approver_role character varying,
    is_active boolean,
    created_at timestamp without time zone
);


--
-- Name: approval_matrices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.approval_matrices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: approval_matrices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.approval_matrices_id_seq OWNED BY public.approval_matrices.id;


--
-- Name: approval_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.approval_requests (
    id integer NOT NULL,
    request_type character varying NOT NULL,
    reference_id integer NOT NULL,
    reference_type character varying NOT NULL,
    requested_by integer NOT NULL,
    amount double precision,
    current_level integer,
    status character varying,
    level_1_approver integer,
    level_1_status character varying,
    level_1_date timestamp without time zone,
    level_2_approver integer,
    level_2_status character varying,
    level_2_date timestamp without time zone,
    level_3_approver integer,
    level_3_status character varying,
    level_3_date timestamp without time zone,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: approval_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.approval_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: approval_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.approval_requests_id_seq OWNED BY public.approval_requests.id;


--
-- Name: asset_inspections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_inspections (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    inspection_date timestamp without time zone,
    inspected_by integer NOT NULL,
    status character varying,
    damage_description text,
    charge_to_guest boolean,
    charge_amount double precision,
    notes text
);


--
-- Name: asset_inspections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asset_inspections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_inspections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asset_inspections_id_seq OWNED BY public.asset_inspections.id;


--
-- Name: asset_maintenance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_maintenance (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    maintenance_type character varying NOT NULL,
    scheduled_date date,
    completed_date date,
    service_provider character varying,
    cost double precision,
    performed_by integer,
    notes text,
    next_service_due date,
    created_at timestamp without time zone
);


--
-- Name: asset_maintenance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asset_maintenance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_maintenance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asset_maintenance_id_seq OWNED BY public.asset_maintenance.id;


--
-- Name: asset_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_mappings (
    id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer NOT NULL,
    serial_number character varying,
    assigned_date timestamp without time zone NOT NULL,
    assigned_by integer,
    notes text,
    is_active boolean NOT NULL,
    unassigned_date timestamp without time zone,
    quantity double precision DEFAULT '1'::double precision NOT NULL
);


--
-- Name: asset_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asset_mappings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asset_mappings_id_seq OWNED BY public.asset_mappings.id;


--
-- Name: asset_registry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_registry (
    id integer NOT NULL,
    asset_tag_id character varying NOT NULL,
    item_id integer NOT NULL,
    serial_number character varying,
    current_location_id integer,
    status character varying NOT NULL,
    purchase_date date,
    warranty_expiry date,
    last_maintenance_date date,
    next_maintenance_due date,
    purchase_master_id integer,
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone
);


--
-- Name: asset_registry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asset_registry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asset_registry_id_seq OWNED BY public.asset_registry.id;


--
-- Name: assigned_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assigned_services (
    id integer NOT NULL,
    service_id integer,
    employee_id integer,
    room_id integer,
    assigned_at timestamp without time zone,
    status public.servicestatus,
    billing_status character varying,
    last_used_at timestamp without time zone,
    override_charges double precision
);


--
-- Name: assigned_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assigned_services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assigned_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assigned_services_id_seq OWNED BY public.assigned_services.id;


--
-- Name: attendances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendances (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    date date NOT NULL,
    status character varying NOT NULL
);


--
-- Name: attendances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attendances_id_seq OWNED BY public.attendances.id;


--
-- Name: audit_discrepancies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_discrepancies (
    id integer NOT NULL,
    audit_id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer NOT NULL,
    system_quantity double precision NOT NULL,
    physical_quantity double precision NOT NULL,
    discrepancy double precision NOT NULL,
    uom character varying NOT NULL,
    resolved_by integer,
    resolved_at timestamp without time zone,
    notes text,
    created_at timestamp without time zone
);


--
-- Name: audit_discrepancies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_discrepancies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_discrepancies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_discrepancies_id_seq OWNED BY public.audit_discrepancies.id;


--
-- Name: booking_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_rooms (
    id integer NOT NULL,
    booking_id integer,
    room_id integer
);


--
-- Name: booking_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.booking_rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: booking_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.booking_rooms_id_seq OWNED BY public.booking_rooms.id;


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id integer NOT NULL,
    status character varying,
    guest_name character varying NOT NULL,
    guest_mobile character varying,
    guest_email character varying,
    check_in date NOT NULL,
    check_out date NOT NULL,
    adults integer,
    children integer,
    id_card_image_url character varying,
    guest_photo_url character varying,
    user_id integer,
    total_amount double precision,
    advance_deposit double precision DEFAULT 0.0,
    checked_in_at timestamp without time zone
);


--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;


--
-- Name: check_availability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.check_availability (
    id integer NOT NULL,
    name character varying(100),
    email character varying(100),
    phone character varying(20),
    check_in date,
    check_out date,
    guests integer,
    is_active boolean
);


--
-- Name: check_availability_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.check_availability_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: check_availability_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.check_availability_id_seq OWNED BY public.check_availability.id;


--
-- Name: checklist_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checklist_executions (
    id integer NOT NULL,
    checklist_id integer NOT NULL,
    room_id integer,
    location_id integer,
    executed_by integer NOT NULL,
    executed_at timestamp without time zone,
    status character varying,
    completed_at timestamp without time zone,
    notes text
);


--
-- Name: checklist_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checklist_executions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklist_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checklist_executions_id_seq OWNED BY public.checklist_executions.id;


--
-- Name: checklist_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checklist_items (
    id integer NOT NULL,
    checklist_id integer NOT NULL,
    item_text character varying NOT NULL,
    item_type character varying,
    is_required boolean,
    order_index integer
);


--
-- Name: checklist_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checklist_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklist_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checklist_items_id_seq OWNED BY public.checklist_items.id;


--
-- Name: checklist_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checklist_responses (
    id integer NOT NULL,
    execution_id integer NOT NULL,
    item_id integer NOT NULL,
    response character varying NOT NULL,
    status character varying NOT NULL,
    notes text,
    responded_by integer NOT NULL,
    responded_at timestamp without time zone
);


--
-- Name: checklist_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checklist_responses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklist_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checklist_responses_id_seq OWNED BY public.checklist_responses.id;


--
-- Name: checklists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checklists (
    id integer NOT NULL,
    name character varying NOT NULL,
    category character varying NOT NULL,
    module_type character varying NOT NULL,
    description text,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: checklists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checklists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checklists_id_seq OWNED BY public.checklists.id;


--
-- Name: checkout_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkout_payments (
    id integer NOT NULL,
    checkout_id integer NOT NULL,
    payment_method character varying NOT NULL,
    amount double precision NOT NULL,
    transaction_id character varying,
    notes character varying,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: checkout_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checkout_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkout_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkout_payments_id_seq OWNED BY public.checkout_payments.id;


--
-- Name: checkout_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkout_requests (
    id integer NOT NULL,
    booking_id integer,
    package_booking_id integer,
    room_number character varying NOT NULL,
    guest_name character varying NOT NULL,
    status character varying,
    requested_by character varying,
    requested_at timestamp with time zone DEFAULT now(),
    inventory_checked boolean,
    inventory_checked_by character varying,
    inventory_checked_at timestamp without time zone,
    inventory_notes text,
    checkout_id integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    employee_id integer,
    completed_at timestamp without time zone,
    inventory_data json
);


--
-- Name: checkout_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checkout_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkout_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkout_requests_id_seq OWNED BY public.checkout_requests.id;


--
-- Name: checkout_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkout_verifications (
    id integer NOT NULL,
    checkout_id integer NOT NULL,
    room_number character varying NOT NULL,
    housekeeping_status character varying,
    housekeeping_notes text,
    housekeeping_approved_by character varying,
    housekeeping_approved_at timestamp without time zone,
    consumables_audit_data json,
    consumables_total_charge double precision,
    asset_damages json,
    asset_damage_total double precision,
    key_card_returned boolean,
    key_card_fee double precision,
    created_at timestamp with time zone DEFAULT now(),
    checkout_request_id integer
);


--
-- Name: checkout_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checkout_verifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkout_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkout_verifications_id_seq OWNED BY public.checkout_verifications.id;


--
-- Name: checkouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkouts (
    id integer NOT NULL,
    room_total double precision,
    food_total double precision,
    service_total double precision,
    package_total double precision,
    tax_amount double precision,
    discount_amount double precision,
    grand_total double precision,
    guest_name character varying,
    room_number character varying,
    created_at timestamp with time zone DEFAULT now(),
    checkout_date timestamp without time zone,
    payment_method character varying,
    booking_id integer,
    package_booking_id integer,
    payment_status character varying,
    late_checkout_fee double precision DEFAULT 0.0,
    consumables_charges double precision DEFAULT 0.0,
    asset_damage_charges double precision DEFAULT 0.0,
    key_card_fee double precision DEFAULT 0.0,
    advance_deposit double precision DEFAULT 0.0,
    tips_gratuity double precision DEFAULT 0.0,
    guest_gstin character varying,
    is_b2b boolean DEFAULT false,
    invoice_number character varying,
    invoice_pdf_path character varying,
    gate_pass_path character varying,
    feedback_sent boolean DEFAULT false,
    bill_details json
);


--
-- Name: checkouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checkouts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkouts_id_seq OWNED BY public.checkouts.id;


--
-- Name: consumable_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consumable_usage (
    id integer NOT NULL,
    room_id integer NOT NULL,
    booking_id integer,
    item_id integer NOT NULL,
    quantity_used double precision NOT NULL,
    uom character varying NOT NULL,
    usage_type character varying NOT NULL,
    usage_date timestamp without time zone,
    recorded_by integer NOT NULL,
    charge_amount double precision,
    notes text
);


--
-- Name: consumable_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.consumable_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: consumable_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.consumable_usage_id_seq OWNED BY public.consumable_usage.id;


--
-- Name: cost_centers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cost_centers (
    id integer NOT NULL,
    name character varying NOT NULL,
    code character varying,
    description text,
    is_active boolean,
    created_at timestamp without time zone
);


--
-- Name: cost_centers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cost_centers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cost_centers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cost_centers_id_seq OWNED BY public.cost_centers.id;


--
-- Name: damage_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.damage_reports (
    id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer,
    room_id integer,
    damage_type character varying NOT NULL,
    description text NOT NULL,
    reported_by integer NOT NULL,
    reported_at timestamp without time zone,
    status character varying,
    approved_by integer,
    approved_at timestamp without time zone,
    resolution_action character varying,
    charge_to_guest boolean,
    charge_amount double precision,
    notes text,
    resolved_at timestamp without time zone
);


--
-- Name: damage_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.damage_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: damage_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.damage_reports_id_seq OWNED BY public.damage_reports.id;


--
-- Name: employee_inventory_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee_inventory_assignments (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    assigned_service_id integer,
    item_id integer NOT NULL,
    quantity_assigned double precision NOT NULL,
    quantity_used double precision NOT NULL,
    quantity_returned double precision NOT NULL,
    status character varying,
    is_returned boolean,
    assigned_at timestamp without time zone,
    returned_at timestamp without time zone,
    notes character varying
);


--
-- Name: employee_inventory_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employee_inventory_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee_inventory_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employee_inventory_assignments_id_seq OWNED BY public.employee_inventory_assignments.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    name character varying,
    role character varying,
    salary double precision,
    join_date date,
    image_url character varying,
    user_id integer
);


--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: eod_audit_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eod_audit_items (
    id integer NOT NULL,
    audit_id integer NOT NULL,
    item_id integer NOT NULL,
    system_quantity double precision NOT NULL,
    physical_quantity double precision NOT NULL,
    variance double precision,
    uom character varying NOT NULL
);


--
-- Name: eod_audit_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.eod_audit_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eod_audit_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.eod_audit_items_id_seq OWNED BY public.eod_audit_items.id;


--
-- Name: eod_audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eod_audits (
    id integer NOT NULL,
    audit_date date NOT NULL,
    location_id integer NOT NULL,
    audited_by integer NOT NULL,
    system_stock_value double precision,
    physical_stock_value double precision,
    variance double precision,
    variance_percentage double precision,
    notes text,
    created_at timestamp without time zone
);


--
-- Name: eod_audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.eod_audits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eod_audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.eod_audits_id_seq OWNED BY public.eod_audits.id;


--
-- Name: expenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.expenses (
    id integer NOT NULL,
    category character varying NOT NULL,
    amount double precision NOT NULL,
    date date NOT NULL,
    description character varying,
    employee_id integer,
    image character varying,
    created_at timestamp without time zone,
    rcm_applicable boolean DEFAULT false NOT NULL,
    rcm_tax_rate double precision,
    nature_of_supply character varying,
    original_bill_no character varying,
    self_invoice_number character varying,
    vendor_id integer,
    rcm_liability_date date,
    itc_eligible boolean DEFAULT true NOT NULL,
    department character varying
);


--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.expenses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.expenses_id_seq OWNED BY public.expenses.id;


--
-- Name: expiry_alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.expiry_alerts (
    id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer NOT NULL,
    batch_number character varying,
    expiry_date date NOT NULL,
    days_until_expiry integer NOT NULL,
    status character varying,
    created_at timestamp without time zone,
    acknowledged_at timestamp without time zone,
    acknowledged_by integer
);


--
-- Name: expiry_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.expiry_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: expiry_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.expiry_alerts_id_seq OWNED BY public.expiry_alerts.id;


--
-- Name: fire_safety_equipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fire_safety_equipment (
    id integer NOT NULL,
    equipment_type character varying NOT NULL,
    item_id integer,
    asset_id character varying NOT NULL,
    qr_code character varying,
    location_id integer NOT NULL,
    floor character varying,
    zone character varying,
    manufacturer character varying,
    model character varying,
    capacity character varying,
    installation_date date,
    expiry_date date,
    last_inspection_date date,
    next_inspection_date date,
    last_service_date date,
    next_service_date date,
    status character varying,
    certification_number character varying,
    certification_expiry date,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: fire_safety_equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fire_safety_equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fire_safety_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fire_safety_equipment_id_seq OWNED BY public.fire_safety_equipment.id;


--
-- Name: fire_safety_incidents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fire_safety_incidents (
    id integer NOT NULL,
    equipment_id integer,
    incident_date timestamp without time zone,
    incident_type character varying NOT NULL,
    location_id integer NOT NULL,
    reported_by integer NOT NULL,
    equipment_used boolean,
    damage_assessment text,
    action_taken text,
    refill_required boolean,
    investigation_report text,
    notes text
);


--
-- Name: fire_safety_incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fire_safety_incidents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fire_safety_incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fire_safety_incidents_id_seq OWNED BY public.fire_safety_incidents.id;


--
-- Name: fire_safety_inspections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fire_safety_inspections (
    id integer NOT NULL,
    equipment_id integer NOT NULL,
    inspection_date timestamp without time zone,
    inspected_by integer NOT NULL,
    inspection_type character varying NOT NULL,
    status character varying NOT NULL,
    pressure_check character varying,
    visual_check character varying,
    functional_check character varying,
    notes text,
    next_inspection_date date
);


--
-- Name: fire_safety_inspections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fire_safety_inspections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fire_safety_inspections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fire_safety_inspections_id_seq OWNED BY public.fire_safety_inspections.id;


--
-- Name: fire_safety_maintenance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fire_safety_maintenance (
    id integer NOT NULL,
    equipment_id integer NOT NULL,
    service_type character varying NOT NULL,
    service_date timestamp without time zone,
    service_provider character varying,
    cost double precision,
    performed_by integer,
    test_certificate_number character varying,
    next_service_due date,
    notes text
);


--
-- Name: fire_safety_maintenance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fire_safety_maintenance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fire_safety_maintenance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fire_safety_maintenance_id_seq OWNED BY public.fire_safety_maintenance.id;


--
-- Name: first_aid_kit_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.first_aid_kit_items (
    id integer NOT NULL,
    kit_id integer NOT NULL,
    item_id integer NOT NULL,
    par_quantity integer NOT NULL,
    current_quantity integer,
    expiry_date date,
    last_restocked date
);


--
-- Name: first_aid_kit_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.first_aid_kit_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: first_aid_kit_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.first_aid_kit_items_id_seq OWNED BY public.first_aid_kit_items.id;


--
-- Name: first_aid_kits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.first_aid_kits (
    id integer NOT NULL,
    kit_number character varying NOT NULL,
    location_id integer NOT NULL,
    last_checked_date date,
    next_check_date date,
    expiry_items_count integer,
    status character varying,
    checked_by integer,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: first_aid_kits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.first_aid_kits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: first_aid_kits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.first_aid_kits_id_seq OWNED BY public.first_aid_kits.id;


--
-- Name: food_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.food_categories (
    id integer NOT NULL,
    name character varying NOT NULL,
    image character varying
);


--
-- Name: food_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.food_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: food_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.food_categories_id_seq OWNED BY public.food_categories.id;


--
-- Name: food_item_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.food_item_images (
    id integer NOT NULL,
    image_url character varying,
    item_id integer
);


--
-- Name: food_item_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.food_item_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: food_item_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.food_item_images_id_seq OWNED BY public.food_item_images.id;


--
-- Name: food_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.food_items (
    id integer NOT NULL,
    name character varying,
    description character varying,
    price integer,
    available character varying,
    category_id integer
);


--
-- Name: food_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.food_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: food_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.food_items_id_seq OWNED BY public.food_items.id;


--
-- Name: food_order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.food_order_items (
    id integer NOT NULL,
    order_id integer,
    food_item_id integer,
    quantity integer
);


--
-- Name: food_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.food_order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: food_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.food_order_items_id_seq OWNED BY public.food_order_items.id;


--
-- Name: food_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.food_orders (
    id integer NOT NULL,
    room_id integer,
    amount double precision,
    assigned_employee_id integer,
    status character varying,
    billing_status character varying,
    created_at timestamp without time zone,
    order_type character varying DEFAULT 'dine_in'::character varying,
    delivery_request text,
    payment_method character varying,
    payment_time timestamp without time zone,
    gst_amount double precision,
    total_with_gst double precision,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: food_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.food_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: food_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.food_orders_id_seq OWNED BY public.food_orders.id;


--
-- Name: gallery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gallery (
    id integer NOT NULL,
    image_url character varying(255),
    caption character varying(255),
    is_active boolean
);


--
-- Name: gallery_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gallery_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gallery_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gallery_id_seq OWNED BY public.gallery.id;


--
-- Name: goods_received_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.goods_received_notes (
    id integer NOT NULL,
    grn_number character varying NOT NULL,
    po_id integer NOT NULL,
    received_by integer NOT NULL,
    verified_by integer,
    status public.grnstatus,
    received_date timestamp without time zone,
    verified_date timestamp without time zone,
    notes text
);


--
-- Name: goods_received_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.goods_received_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: goods_received_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.goods_received_notes_id_seq OWNED BY public.goods_received_notes.id;


--
-- Name: grn_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grn_items (
    id integer NOT NULL,
    grn_id integer NOT NULL,
    po_item_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity double precision NOT NULL,
    uom character varying NOT NULL,
    expiry_date date,
    batch_number character varying,
    unit_price double precision NOT NULL,
    location_id integer NOT NULL,
    barcode_generated boolean
);


--
-- Name: grn_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grn_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grn_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grn_items_id_seq OWNED BY public.grn_items.id;


--
-- Name: guest_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_suggestions (
    id integer NOT NULL,
    guest_name character varying(100) NOT NULL,
    contact_info character varying(100),
    suggestion text NOT NULL,
    status character varying(50),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: guest_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guest_suggestions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guest_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guest_suggestions_id_seq OWNED BY public.guest_suggestions.id;


--
-- Name: header_banner; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.header_banner (
    id integer NOT NULL,
    title character varying(255),
    subtitle text,
    image_url character varying(255),
    is_active boolean
);


--
-- Name: header_banner_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.header_banner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: header_banner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.header_banner_id_seq OWNED BY public.header_banner.id;


--
-- Name: indent_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.indent_items (
    id integer NOT NULL,
    indent_id integer NOT NULL,
    item_id integer NOT NULL,
    requested_quantity double precision NOT NULL,
    approved_quantity double precision,
    issued_quantity double precision,
    uom character varying NOT NULL,
    notes text
);


--
-- Name: indent_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.indent_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: indent_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.indent_items_id_seq OWNED BY public.indent_items.id;


--
-- Name: indents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.indents (
    id integer NOT NULL,
    indent_number character varying NOT NULL,
    requested_from_location_id integer NOT NULL,
    requested_to_location_id integer NOT NULL,
    status public.indentstatus,
    requested_by integer NOT NULL,
    approved_by integer,
    requested_date timestamp without time zone,
    approved_date timestamp without time zone,
    fulfilled_date timestamp without time zone,
    notes text
);


--
-- Name: indents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.indents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: indents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.indents_id_seq OWNED BY public.indents.id;


--
-- Name: inventory_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_categories (
    id integer NOT NULL,
    name character varying NOT NULL,
    description text,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    parent_department character varying,
    gst_tax_rate double precision DEFAULT 0.0,
    is_perishable boolean DEFAULT false,
    is_asset_fixed boolean DEFAULT false,
    is_sellable boolean DEFAULT false,
    track_laundry boolean DEFAULT false,
    allow_partial_usage boolean DEFAULT false,
    consumable_instant boolean DEFAULT false,
    classification character varying,
    hsn_sac_code character varying,
    default_gst_rate double precision DEFAULT 0.0,
    cess_percentage double precision DEFAULT 0.0,
    itc_eligibility character varying DEFAULT 'Eligible'::character varying,
    is_capital_good boolean DEFAULT false
);


--
-- Name: inventory_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_categories_id_seq OWNED BY public.inventory_categories.id;


--
-- Name: inventory_expenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_expenses (
    id integer NOT NULL,
    item_id integer NOT NULL,
    cost_center_id integer NOT NULL,
    quantity double precision NOT NULL,
    uom character varying NOT NULL,
    unit_cost double precision NOT NULL,
    total_cost double precision NOT NULL,
    issued_to character varying,
    issued_by integer NOT NULL,
    issued_date timestamp without time zone,
    notes text
);


--
-- Name: inventory_expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_expenses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_expenses_id_seq OWNED BY public.inventory_expenses.id;


--
-- Name: inventory_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_items (
    id integer NOT NULL,
    name character varying NOT NULL,
    description text,
    category_id integer NOT NULL,
    sku character varying,
    barcode character varying,
    base_uom_id integer,
    unit_price double precision,
    selling_price double precision,
    track_expiry boolean,
    track_serial boolean,
    track_batch boolean,
    min_stock_level double precision,
    max_stock_level double precision,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    hsn_code character varying,
    gst_rate double precision DEFAULT 0,
    item_code character varying,
    sub_category character varying,
    image_path character varying,
    location character varying,
    track_serial_number boolean DEFAULT false,
    is_sellable_to_guest boolean DEFAULT false,
    track_laundry_cycle boolean DEFAULT false,
    is_asset_fixed boolean DEFAULT false,
    maintenance_schedule_days integer,
    complimentary_limit integer,
    ingredient_yield_percentage double precision,
    preferred_vendor_id integer,
    vendor_item_code character varying,
    lead_time_days integer,
    is_perishable boolean DEFAULT false,
    unit character varying DEFAULT 'pcs'::character varying NOT NULL,
    current_stock double precision DEFAULT 0.0 NOT NULL
);


--
-- Name: inventory_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_items_id_seq OWNED BY public.inventory_items.id;


--
-- Name: inventory_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_transactions (
    id integer NOT NULL,
    item_id integer NOT NULL,
    transaction_type character varying NOT NULL,
    quantity double precision NOT NULL,
    unit_price double precision,
    total_amount double precision,
    reference_number character varying,
    purchase_master_id integer,
    notes text,
    created_by integer,
    created_at timestamp without time zone NOT NULL,
    department character varying
);


--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_transactions_id_seq OWNED BY public.inventory_transactions.id;


--
-- Name: journal_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal_entries (
    id integer NOT NULL,
    entry_number character varying NOT NULL,
    entry_date timestamp with time zone DEFAULT now() NOT NULL,
    reference_type character varying,
    reference_id integer,
    description text NOT NULL,
    total_amount double precision NOT NULL,
    created_by integer,
    notes text,
    is_reversed boolean,
    reversed_entry_id integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


--
-- Name: journal_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.journal_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journal_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.journal_entries_id_seq OWNED BY public.journal_entries.id;


--
-- Name: journal_entry_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal_entry_lines (
    id integer NOT NULL,
    entry_id integer NOT NULL,
    debit_ledger_id integer,
    credit_ledger_id integer,
    amount double precision NOT NULL,
    description text,
    line_number integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: journal_entry_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.journal_entry_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journal_entry_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.journal_entry_lines_id_seq OWNED BY public.journal_entry_lines.id;


--
-- Name: key_management; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.key_management (
    id integer NOT NULL,
    key_number character varying NOT NULL,
    key_type character varying NOT NULL,
    location_id integer,
    room_id integer,
    description text,
    current_holder integer,
    status character varying,
    issued_date timestamp without time zone,
    returned_date timestamp without time zone,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: key_management_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.key_management_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: key_management_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.key_management_id_seq OWNED BY public.key_management.id;


--
-- Name: key_movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.key_movements (
    id integer NOT NULL,
    key_id integer NOT NULL,
    movement_type character varying NOT NULL,
    from_user_id integer,
    to_user_id integer,
    purpose text,
    movement_date timestamp without time zone,
    returned_date timestamp without time zone,
    notes text
);


--
-- Name: key_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.key_movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: key_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.key_movements_id_seq OWNED BY public.key_movements.id;


--
-- Name: laundry_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.laundry_services (
    id integer NOT NULL,
    vendor_id integer,
    name character varying NOT NULL,
    contact_person character varying,
    phone character varying,
    email character varying,
    rate_per_kg double precision,
    rate_per_piece double precision,
    turnaround_time_days integer,
    is_active boolean,
    notes text,
    created_at timestamp without time zone
);


--
-- Name: laundry_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.laundry_services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: laundry_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.laundry_services_id_seq OWNED BY public.laundry_services.id;


--
-- Name: leaves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leaves (
    id integer NOT NULL,
    employee_id integer,
    from_date date,
    to_date date,
    reason character varying,
    leave_type character varying,
    status character varying
);


--
-- Name: leaves_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.leaves_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leaves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.leaves_id_seq OWNED BY public.leaves.id;


--
-- Name: legal_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_documents (
    id integer NOT NULL,
    name character varying NOT NULL,
    document_type character varying,
    file_path character varying NOT NULL,
    uploaded_at timestamp with time zone DEFAULT now(),
    description character varying
);


--
-- Name: legal_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.legal_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legal_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legal_documents_id_seq OWNED BY public.legal_documents.id;


--
-- Name: linen_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linen_items (
    id integer NOT NULL,
    item_id integer NOT NULL,
    rfid_tag character varying,
    barcode character varying,
    quality_grade character varying,
    wash_count integer,
    max_washes integer,
    current_state public.stockstate,
    current_location_id integer,
    current_room_id integer,
    purchase_date date,
    first_use_date date,
    discard_date date,
    discard_reason character varying,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: linen_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.linen_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: linen_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.linen_items_id_seq OWNED BY public.linen_items.id;


--
-- Name: linen_movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linen_movements (
    id integer NOT NULL,
    item_id integer NOT NULL,
    room_id integer,
    from_state public.stockstate,
    to_state public.stockstate NOT NULL,
    quantity integer NOT NULL,
    movement_date timestamp without time zone,
    moved_by integer NOT NULL,
    notes text
);


--
-- Name: linen_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.linen_movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: linen_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.linen_movements_id_seq OWNED BY public.linen_movements.id;


--
-- Name: linen_stocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linen_stocks (
    id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer NOT NULL,
    state public.stockstate NOT NULL,
    quantity integer,
    last_updated timestamp without time zone
);


--
-- Name: linen_stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.linen_stocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: linen_stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.linen_stocks_id_seq OWNED BY public.linen_stocks.id;


--
-- Name: linen_wash_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linen_wash_logs (
    id integer NOT NULL,
    linen_item_id integer NOT NULL,
    wash_date timestamp without time zone,
    wash_count_after integer NOT NULL,
    quality_after character varying,
    laundry_provider character varying,
    cost double precision,
    notes text
);


--
-- Name: linen_wash_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.linen_wash_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: linen_wash_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.linen_wash_logs_id_seq OWNED BY public.linen_wash_logs.id;


--
-- Name: location_stocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_stocks (
    id integer NOT NULL,
    location_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity double precision NOT NULL,
    last_updated timestamp without time zone
);


--
-- Name: location_stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.location_stocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.location_stocks_id_seq OWNED BY public.location_stocks.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    name character varying NOT NULL,
    code character varying,
    location_type public.locationtype NOT NULL,
    parent_location_id integer,
    description text,
    is_active boolean,
    created_at timestamp without time zone,
    location_code character varying,
    is_inventory_point boolean DEFAULT false,
    building character varying DEFAULT 'Main Block'::character varying NOT NULL,
    floor character varying,
    room_area character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: lost_found; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lost_found (
    id integer NOT NULL,
    item_description text NOT NULL,
    found_date date NOT NULL,
    found_by character varying,
    found_by_employee_id integer,
    room_number character varying,
    location character varying,
    status character varying NOT NULL,
    claimed_by character varying,
    claimed_date date,
    claimed_contact character varying,
    notes text,
    image_url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone
);


--
-- Name: lost_found_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lost_found_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lost_found_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lost_found_id_seq OWNED BY public.lost_found.id;


--
-- Name: maintenance_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maintenance_tickets (
    id integer NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    category character varying NOT NULL,
    item_id integer,
    location_id integer,
    room_id integer,
    priority character varying,
    status character varying,
    reported_by integer NOT NULL,
    assigned_to integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    resolution_notes text,
    completed_at timestamp without time zone
);


--
-- Name: maintenance_tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maintenance_tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maintenance_tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maintenance_tickets_id_seq OWNED BY public.maintenance_tickets.id;


--
-- Name: nearby_attraction_banners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nearby_attraction_banners (
    id integer NOT NULL,
    title character varying(255),
    subtitle text,
    image_url character varying(255),
    is_active boolean,
    map_link character varying(512)
);


--
-- Name: nearby_attraction_banners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nearby_attraction_banners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nearby_attraction_banners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nearby_attraction_banners_id_seq OWNED BY public.nearby_attraction_banners.id;


--
-- Name: nearby_attractions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nearby_attractions (
    id integer NOT NULL,
    title character varying(255),
    description text,
    image_url character varying(255),
    is_active boolean,
    map_link character varying(512)
);


--
-- Name: nearby_attractions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nearby_attractions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nearby_attractions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nearby_attractions_id_seq OWNED BY public.nearby_attractions.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    type public.notificationtype NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    is_read boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    read_at timestamp with time zone,
    entity_type character varying(50),
    entity_id integer
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: office_inventory_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.office_inventory_items (
    id integer NOT NULL,
    item_id integer NOT NULL,
    item_type character varying NOT NULL,
    department_id integer,
    location_id integer,
    assigned_to integer,
    asset_tag character varying,
    serial_number character varying,
    purchase_date date,
    purchase_price double precision,
    warranty_expiry date,
    amc_expiry date,
    status character varying,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: office_inventory_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.office_inventory_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: office_inventory_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.office_inventory_items_id_seq OWNED BY public.office_inventory_items.id;


--
-- Name: office_requisitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.office_requisitions (
    id integer NOT NULL,
    req_number character varying NOT NULL,
    item_id integer NOT NULL,
    requested_by integer NOT NULL,
    department_id integer NOT NULL,
    quantity double precision NOT NULL,
    uom character varying NOT NULL,
    purpose text,
    status character varying,
    supervisor_approval integer,
    admin_approval integer,
    approved_date timestamp without time zone,
    issued_date timestamp without time zone,
    issued_by integer,
    notes text,
    created_at timestamp without time zone
);


--
-- Name: office_requisitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.office_requisitions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: office_requisitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.office_requisitions_id_seq OWNED BY public.office_requisitions.id;


--
-- Name: outlet_stocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outlet_stocks (
    id integer NOT NULL,
    outlet_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity double precision,
    uom character varying NOT NULL,
    par_level double precision,
    last_updated timestamp without time zone
);


--
-- Name: outlet_stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outlet_stocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outlet_stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outlet_stocks_id_seq OWNED BY public.outlet_stocks.id;


--
-- Name: outlets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outlets (
    id integer NOT NULL,
    name character varying NOT NULL,
    code character varying,
    location_id integer,
    outlet_type character varying NOT NULL,
    is_active boolean,
    description text,
    created_at timestamp without time zone
);


--
-- Name: outlets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outlets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outlets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outlets_id_seq OWNED BY public.outlets.id;


--
-- Name: package_booking_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package_booking_rooms (
    id integer NOT NULL,
    package_booking_id integer,
    room_id integer
);


--
-- Name: package_booking_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.package_booking_rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: package_booking_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.package_booking_rooms_id_seq OWNED BY public.package_booking_rooms.id;


--
-- Name: package_bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package_bookings (
    id integer NOT NULL,
    package_id integer,
    user_id integer,
    guest_name character varying NOT NULL,
    guest_email character varying,
    guest_mobile character varying,
    check_in date NOT NULL,
    check_out date NOT NULL,
    adults integer,
    children integer,
    id_card_image_url character varying,
    guest_photo_url character varying,
    status character varying,
    advance_deposit double precision DEFAULT 0.0,
    checked_in_at timestamp without time zone,
    food_preferences text,
    special_requests text
);


--
-- Name: package_bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.package_bookings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: package_bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.package_bookings_id_seq OWNED BY public.package_bookings.id;


--
-- Name: package_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package_images (
    id integer NOT NULL,
    package_id integer,
    image_url character varying NOT NULL
);


--
-- Name: package_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.package_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: package_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.package_images_id_seq OWNED BY public.package_images.id;


--
-- Name: packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.packages (
    id integer NOT NULL,
    title character varying NOT NULL,
    description character varying,
    price double precision NOT NULL,
    booking_type character varying,
    room_types character varying,
    theme character varying,
    default_adults integer DEFAULT 2,
    default_children integer DEFAULT 0,
    max_stay_days integer,
    food_included character varying,
    food_timing character varying,
    complimentary text
);


--
-- Name: packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.packages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.packages_id_seq OWNED BY public.packages.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    booking_id integer,
    amount double precision,
    method character varying,
    status character varying,
    created_at timestamp without time zone
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: perishable_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.perishable_batches (
    id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer NOT NULL,
    batch_number character varying NOT NULL,
    quantity double precision NOT NULL,
    uom character varying NOT NULL,
    expiry_date date NOT NULL,
    received_date date,
    created_at timestamp without time zone
);


--
-- Name: perishable_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.perishable_batches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: perishable_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.perishable_batches_id_seq OWNED BY public.perishable_batches.id;


--
-- Name: plan_weddings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_weddings (
    id integer NOT NULL,
    title character varying(255),
    description text,
    image_url character varying(255),
    is_active boolean
);


--
-- Name: plan_weddings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plan_weddings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plan_weddings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plan_weddings_id_seq OWNED BY public.plan_weddings.id;


--
-- Name: po_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.po_items (
    id integer NOT NULL,
    po_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity double precision NOT NULL,
    uom character varying NOT NULL,
    unit_price double precision NOT NULL,
    total_price double precision NOT NULL,
    received_quantity double precision
);


--
-- Name: po_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.po_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: po_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.po_items_id_seq OWNED BY public.po_items.id;


--
-- Name: purchase_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_details (
    id integer NOT NULL,
    purchase_master_id integer NOT NULL,
    item_id integer NOT NULL,
    hsn_code character varying,
    quantity double precision NOT NULL,
    unit character varying NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    gst_rate numeric(5,2) NOT NULL,
    cgst_amount numeric(10,2) NOT NULL,
    sgst_amount numeric(10,2) NOT NULL,
    igst_amount numeric(10,2) NOT NULL,
    discount numeric(10,2) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    notes text
);


--
-- Name: purchase_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_details_id_seq OWNED BY public.purchase_details.id;


--
-- Name: purchase_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_entries (
    id integer NOT NULL,
    entry_number character varying NOT NULL,
    invoice_number character varying NOT NULL,
    invoice_date date NOT NULL,
    vendor_id integer NOT NULL,
    vendor_address text,
    vendor_gstin character varying,
    tax_inclusive boolean,
    taxable_amount double precision,
    total_gst_amount double precision,
    total_invoice_value double precision,
    status character varying,
    location_id integer NOT NULL,
    created_by integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    notes text
);


--
-- Name: purchase_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_entries_id_seq OWNED BY public.purchase_entries.id;


--
-- Name: purchase_entry_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_entry_items (
    id integer NOT NULL,
    purchase_entry_id integer NOT NULL,
    item_id integer NOT NULL,
    hsn_code character varying,
    uom character varying NOT NULL,
    gst_rate double precision,
    quantity double precision NOT NULL,
    rate double precision NOT NULL,
    base_amount double precision NOT NULL,
    gst_amount double precision,
    total_amount double precision NOT NULL,
    stock_updated boolean,
    stock_level_id integer
);


--
-- Name: purchase_entry_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_entry_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_entry_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_entry_items_id_seq OWNED BY public.purchase_entry_items.id;


--
-- Name: purchase_masters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_masters (
    id integer NOT NULL,
    purchase_number character varying NOT NULL,
    vendor_id integer NOT NULL,
    purchase_date date NOT NULL,
    expected_delivery_date date,
    invoice_number character varying,
    invoice_date date,
    gst_number character varying,
    payment_terms character varying,
    payment_status character varying NOT NULL,
    sub_total numeric(10,2) NOT NULL,
    cgst numeric(10,2) NOT NULL,
    sgst numeric(10,2) NOT NULL,
    igst numeric(10,2) NOT NULL,
    discount numeric(10,2) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    notes text,
    status character varying NOT NULL,
    created_by integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    payment_method character varying,
    destination_location_id integer
);


--
-- Name: purchase_masters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_masters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_masters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_masters_id_seq OWNED BY public.purchase_masters.id;


--
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_orders (
    id integer NOT NULL,
    po_number character varying NOT NULL,
    indent_id integer,
    vendor_name character varying NOT NULL,
    vendor_email character varying,
    vendor_phone character varying,
    status public.postatus,
    total_amount double precision,
    created_by integer NOT NULL,
    approved_by integer,
    created_at timestamp without time zone,
    sent_at timestamp without time zone,
    expected_delivery_date date,
    notes text
);


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_orders_id_seq OWNED BY public.purchase_orders.id;


--
-- Name: recipe_ingredients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipe_ingredients (
    id integer NOT NULL,
    recipe_id integer NOT NULL,
    item_id integer,
    quantity double precision NOT NULL,
    uom character varying,
    notes text,
    inventory_item_id integer NOT NULL,
    unit character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recipe_ingredients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recipe_ingredients_id_seq OWNED BY public.recipe_ingredients.id;


--
-- Name: recipes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipes (
    id integer NOT NULL,
    name character varying NOT NULL,
    description text,
    food_item_id integer NOT NULL,
    servings integer,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    prep_time_minutes integer,
    cook_time_minutes integer
);


--
-- Name: recipes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recipes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recipes_id_seq OWNED BY public.recipes.id;


--
-- Name: resort_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resort_info (
    id integer NOT NULL,
    name character varying(255),
    address text,
    facebook character varying(255),
    instagram character varying(255),
    twitter character varying(255),
    linkedin character varying(255),
    is_active boolean
);


--
-- Name: resort_info_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resort_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resort_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resort_info_id_seq OWNED BY public.resort_info.id;


--
-- Name: restock_alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restock_alerts (
    id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer NOT NULL,
    current_stock double precision NOT NULL,
    min_stock double precision NOT NULL,
    alert_type character varying NOT NULL,
    status character varying,
    created_at timestamp without time zone,
    acknowledged_at timestamp without time zone,
    acknowledged_by integer,
    resolved_at timestamp without time zone,
    resolved_by integer,
    notes text
);


--
-- Name: restock_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.restock_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: restock_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.restock_alerts_id_seq OWNED BY public.restock_alerts.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    name character varying(100),
    comment text,
    rating integer,
    is_active boolean
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying,
    permissions text
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: room_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_assets (
    id integer NOT NULL,
    room_id integer NOT NULL,
    item_id integer NOT NULL,
    asset_id character varying NOT NULL,
    qr_code character varying,
    serial_number character varying,
    status character varying,
    purchase_date date,
    purchase_price double precision,
    last_inspection_date date,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: room_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_assets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_assets_id_seq OWNED BY public.room_assets.id;


--
-- Name: room_consumable_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_consumable_assignments (
    id integer NOT NULL,
    room_id integer NOT NULL,
    booking_id integer,
    assigned_at timestamp without time zone,
    assigned_by integer NOT NULL,
    notes text
);


--
-- Name: room_consumable_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_consumable_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_consumable_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_consumable_assignments_id_seq OWNED BY public.room_consumable_assignments.id;


--
-- Name: room_consumable_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_consumable_items (
    id integer NOT NULL,
    assignment_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity_assigned double precision NOT NULL,
    uom character varying NOT NULL
);


--
-- Name: room_consumable_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_consumable_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_consumable_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_consumable_items_id_seq OWNED BY public.room_consumable_items.id;


--
-- Name: room_inventory_audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_inventory_audits (
    id integer NOT NULL,
    room_id integer NOT NULL,
    room_inventory_item_id integer NOT NULL,
    expected_quantity double precision NOT NULL,
    found_quantity double precision NOT NULL,
    consumed_quantity double precision,
    billed_amount double precision,
    audit_date timestamp without time zone,
    audited_by integer NOT NULL,
    notes text
);


--
-- Name: room_inventory_audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_inventory_audits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_inventory_audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_inventory_audits_id_seq OWNED BY public.room_inventory_audits.id;


--
-- Name: room_inventory_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_inventory_items (
    id integer NOT NULL,
    room_id integer NOT NULL,
    item_id integer NOT NULL,
    par_stock double precision,
    current_stock double precision,
    last_audit_date timestamp without time zone,
    last_audited_by integer,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: room_inventory_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_inventory_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_inventory_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_inventory_items_id_seq OWNED BY public.room_inventory_items.id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    number character varying NOT NULL,
    type character varying,
    price double precision,
    status character varying,
    image_url character varying,
    adults integer,
    children integer,
    air_conditioning boolean,
    wifi boolean,
    bathroom boolean,
    living_area boolean,
    terrace boolean,
    parking boolean,
    kitchen boolean,
    family_room boolean,
    bbq boolean,
    garden boolean,
    dining boolean,
    breakfast boolean,
    inventory_location_id integer
);


--
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


--
-- Name: security_equipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security_equipment (
    id integer NOT NULL,
    equipment_type character varying NOT NULL,
    item_id integer,
    asset_id character varying NOT NULL,
    qr_code character varying,
    location_id integer NOT NULL,
    manufacturer character varying,
    model character varying,
    serial_number character varying,
    ip_address character varying,
    installation_date date,
    warranty_expiry date,
    amc_expiry date,
    status character varying,
    assigned_to integer,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: security_equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.security_equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: security_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.security_equipment_id_seq OWNED BY public.security_equipment.id;


--
-- Name: security_maintenance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security_maintenance (
    id integer NOT NULL,
    equipment_id integer NOT NULL,
    maintenance_type character varying NOT NULL,
    scheduled_date date,
    completed_date date,
    service_provider character varying,
    cost double precision,
    performed_by integer,
    description text,
    next_service_due date,
    notes text,
    created_at timestamp without time zone
);


--
-- Name: security_maintenance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.security_maintenance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: security_maintenance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.security_maintenance_id_seq OWNED BY public.security_maintenance.id;


--
-- Name: security_uniforms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security_uniforms (
    id integer NOT NULL,
    item_id integer NOT NULL,
    employee_id integer NOT NULL,
    size character varying,
    quantity integer,
    issued_date date NOT NULL,
    return_date date,
    condition character varying,
    replacement_required boolean,
    notes text,
    created_at timestamp without time zone
);


--
-- Name: security_uniforms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.security_uniforms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: security_uniforms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.security_uniforms_id_seq OWNED BY public.security_uniforms.id;


--
-- Name: service_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_images (
    id integer NOT NULL,
    service_id integer,
    image_url character varying NOT NULL
);


--
-- Name: service_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.service_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: service_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.service_images_id_seq OWNED BY public.service_images.id;


--
-- Name: service_inventory_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_inventory_items (
    service_id integer NOT NULL,
    inventory_item_id integer NOT NULL,
    quantity double precision NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: service_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_requests (
    id integer NOT NULL,
    food_order_id integer,
    room_id integer NOT NULL,
    employee_id integer,
    request_type character varying,
    description text,
    status character varying,
    created_at timestamp without time zone,
    completed_at timestamp without time zone,
    refill_data text
);


--
-- Name: service_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.service_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: service_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.service_requests_id_seq OWNED BY public.service_requests.id;


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    charges double precision NOT NULL,
    created_at timestamp without time zone,
    is_visible_to_guest boolean DEFAULT false NOT NULL,
    average_completion_time character varying,
    gst_rate double precision DEFAULT 0.18
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- Name: signature_experiences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.signature_experiences (
    id integer NOT NULL,
    title character varying(255),
    description text,
    image_url character varying(255),
    is_active boolean
);


--
-- Name: signature_experiences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.signature_experiences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: signature_experiences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.signature_experiences_id_seq OWNED BY public.signature_experiences.id;


--
-- Name: stock_issue_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_issue_details (
    id integer NOT NULL,
    issue_id integer NOT NULL,
    item_id integer NOT NULL,
    issued_quantity double precision NOT NULL,
    unit character varying NOT NULL,
    unit_price double precision,
    notes text,
    batch_lot_number character varying,
    cost double precision,
    is_payable boolean DEFAULT false,
    is_paid boolean DEFAULT false,
    rental_price double precision,
    is_damaged boolean DEFAULT false,
    damage_notes text
);


--
-- Name: stock_issue_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_issue_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_issue_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_issue_details_id_seq OWNED BY public.stock_issue_details.id;


--
-- Name: stock_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_issues (
    id integer NOT NULL,
    issue_number character varying NOT NULL,
    requisition_id integer,
    issued_by integer NOT NULL,
    issue_date timestamp without time zone NOT NULL,
    notes text,
    created_at timestamp without time zone NOT NULL,
    source_location_id integer,
    destination_location_id integer
);


--
-- Name: stock_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_issues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_issues_id_seq OWNED BY public.stock_issues.id;


--
-- Name: stock_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_levels (
    id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer NOT NULL,
    quantity double precision,
    uom character varying NOT NULL,
    expiry_date date,
    batch_number character varying,
    last_updated timestamp without time zone
);


--
-- Name: stock_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_levels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_levels_id_seq OWNED BY public.stock_levels.id;


--
-- Name: stock_movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_movements (
    id integer NOT NULL,
    item_id integer NOT NULL,
    movement_type character varying NOT NULL,
    from_location_id integer,
    to_location_id integer NOT NULL,
    quantity double precision NOT NULL,
    uom character varying NOT NULL,
    batch_number character varying,
    expiry_date date,
    movement_date timestamp without time zone,
    moved_by integer NOT NULL,
    reference_number character varying,
    notes text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: stock_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_movements_id_seq OWNED BY public.stock_movements.id;


--
-- Name: stock_requisition_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_requisition_details (
    id integer NOT NULL,
    requisition_id integer NOT NULL,
    item_id integer NOT NULL,
    requested_quantity double precision NOT NULL,
    unit character varying NOT NULL,
    notes text,
    approved_quantity double precision
);


--
-- Name: stock_requisition_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_requisition_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_requisition_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_requisition_details_id_seq OWNED BY public.stock_requisition_details.id;


--
-- Name: stock_requisitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_requisitions (
    id integer NOT NULL,
    requisition_number character varying NOT NULL,
    destination_department character varying NOT NULL,
    requested_by integer NOT NULL,
    status character varying NOT NULL,
    notes text,
    approved_by integer,
    approved_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    date_needed date,
    priority character varying DEFAULT 'normal'::character varying
);


--
-- Name: stock_requisitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_requisitions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_requisitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_requisitions_id_seq OWNED BY public.stock_requisitions.id;


--
-- Name: stock_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_usage (
    id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer NOT NULL,
    quantity double precision NOT NULL,
    uom character varying NOT NULL,
    usage_type character varying NOT NULL,
    recipe_id integer,
    food_order_id integer,
    usage_date timestamp without time zone,
    used_by integer NOT NULL,
    notes text
);


--
-- Name: stock_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_usage_id_seq OWNED BY public.stock_usage.id;


--
-- Name: system_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_settings (
    id integer NOT NULL,
    key character varying(100) NOT NULL,
    value text,
    description character varying(255),
    updated_at timestamp with time zone
);


--
-- Name: system_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_settings_id_seq OWNED BY public.system_settings.id;


--
-- Name: units_of_measurement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.units_of_measurement (
    id integer NOT NULL,
    name character varying NOT NULL,
    symbol character varying,
    description text,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: units_of_measurement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.units_of_measurement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units_of_measurement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.units_of_measurement_id_seq OWNED BY public.units_of_measurement.id;


--
-- Name: uom_conversions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uom_conversions (
    id integer NOT NULL,
    item_id integer NOT NULL,
    from_uom character varying NOT NULL,
    to_uom character varying NOT NULL,
    conversion_factor double precision NOT NULL
);


--
-- Name: uom_conversions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uom_conversions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uom_conversions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uom_conversions_id_seq OWNED BY public.uom_conversions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying,
    email character varying,
    hashed_password character varying,
    phone character varying,
    is_active boolean,
    role_id integer
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vendor_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_items (
    id integer NOT NULL,
    vendor_id integer NOT NULL,
    item_id integer NOT NULL,
    unit_price double precision NOT NULL,
    uom character varying NOT NULL,
    effective_from date NOT NULL,
    effective_to date,
    is_current boolean,
    notes text,
    created_at timestamp without time zone
);


--
-- Name: vendor_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vendor_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vendor_items_id_seq OWNED BY public.vendor_items.id;


--
-- Name: vendor_performance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_performance (
    id integer NOT NULL,
    vendor_id integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    on_time_delivery_rate double precision,
    quality_score double precision,
    price_competitiveness double precision,
    total_orders integer,
    total_value double precision,
    notes text,
    created_at timestamp without time zone
);


--
-- Name: vendor_performance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vendor_performance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_performance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vendor_performance_id_seq OWNED BY public.vendor_performance.id;


--
-- Name: vendors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendors (
    id integer NOT NULL,
    name character varying NOT NULL,
    code character varying,
    contact_person character varying,
    email character varying,
    phone character varying,
    address text,
    city character varying,
    state character varying,
    country character varying,
    pincode character varying,
    gst_number character varying,
    pan_number character varying,
    payment_terms character varying,
    vendor_type character varying,
    is_active boolean,
    rating double precision,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_number character varying,
    ifsc_code character varying,
    bank_name character varying,
    upi_id character varying,
    transaction_id character varying,
    company_name character varying,
    gst_registration_type character varying,
    legal_name character varying,
    trade_name character varying,
    qmp_scheme boolean DEFAULT false,
    msme_udyam_no character varying,
    billing_address text,
    billing_state character varying,
    shipping_address text,
    distance_km double precision,
    is_msme_registered boolean DEFAULT false,
    tds_apply boolean DEFAULT false,
    rcm_applicable boolean DEFAULT false,
    preferred_payment_method character varying,
    account_holder_name character varying,
    branch_name character varying,
    upi_mobile_number character varying
);


--
-- Name: vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vendors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vendors_id_seq OWNED BY public.vendors.id;


--
-- Name: vouchers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vouchers (
    id integer NOT NULL,
    code character varying,
    discount_percent double precision,
    expiry_date timestamp without time zone
);


--
-- Name: vouchers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vouchers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vouchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vouchers_id_seq OWNED BY public.vouchers.id;


--
-- Name: wastage_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wastage_logs (
    id integer NOT NULL,
    item_id integer NOT NULL,
    location_id integer NOT NULL,
    quantity double precision NOT NULL,
    uom character varying NOT NULL,
    reason character varying NOT NULL,
    wastage_date timestamp without time zone,
    logged_by integer NOT NULL,
    notes text
);


--
-- Name: wastage_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wastage_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wastage_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wastage_logs_id_seq OWNED BY public.wastage_logs.id;


--
-- Name: waste_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.waste_logs (
    id integer NOT NULL,
    item_id integer,
    batch_number character varying,
    expiry_date date,
    quantity double precision NOT NULL,
    unit character varying NOT NULL,
    reason_code character varying NOT NULL,
    photo_path character varying,
    notes text,
    reported_by integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    log_number character varying,
    location_id integer,
    action_taken character varying,
    waste_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    food_item_id integer,
    is_food_item boolean DEFAULT false NOT NULL
);


--
-- Name: waste_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.waste_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: waste_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.waste_logs_id_seq OWNED BY public.waste_logs.id;


--
-- Name: work_order_part_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_order_part_issues (
    id integer NOT NULL,
    work_order_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity double precision NOT NULL,
    uom character varying NOT NULL,
    from_location_id integer NOT NULL,
    issued_by integer NOT NULL,
    issued_date timestamp without time zone,
    notes text
);


--
-- Name: work_order_part_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_order_part_issues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_order_part_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_order_part_issues_id_seq OWNED BY public.work_order_part_issues.id;


--
-- Name: work_order_parts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_order_parts (
    id integer NOT NULL,
    work_order_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity_required double precision NOT NULL,
    quantity_issued double precision,
    uom character varying NOT NULL,
    notes text
);


--
-- Name: work_order_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_order_parts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_order_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_order_parts_id_seq OWNED BY public.work_order_parts.id;


--
-- Name: work_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_orders (
    id integer NOT NULL,
    wo_number character varying NOT NULL,
    asset_id integer,
    location_id integer,
    title character varying NOT NULL,
    description text,
    work_type character varying NOT NULL,
    priority character varying,
    status public.workorderstatus,
    reported_by integer NOT NULL,
    assigned_to integer,
    scheduled_date timestamp without time zone,
    started_date timestamp without time zone,
    completed_date timestamp without time zone,
    estimated_cost double precision,
    actual_cost double precision,
    service_provider character varying,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: work_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_orders_id_seq OWNED BY public.work_orders.id;


--
-- Name: working_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.working_logs (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    date date NOT NULL,
    check_in_time time without time zone,
    check_out_time time without time zone,
    location character varying
);


--
-- Name: working_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.working_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: working_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.working_logs_id_seq OWNED BY public.working_logs.id;


--
-- Name: account_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_groups ALTER COLUMN id SET DEFAULT nextval('public.account_groups_id_seq'::regclass);


--
-- Name: account_ledgers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_ledgers ALTER COLUMN id SET DEFAULT nextval('public.account_ledgers_id_seq'::regclass);


--
-- Name: approval_matrices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approval_matrices ALTER COLUMN id SET DEFAULT nextval('public.approval_matrices_id_seq'::regclass);


--
-- Name: approval_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approval_requests ALTER COLUMN id SET DEFAULT nextval('public.approval_requests_id_seq'::regclass);


--
-- Name: asset_inspections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_inspections ALTER COLUMN id SET DEFAULT nextval('public.asset_inspections_id_seq'::regclass);


--
-- Name: asset_maintenance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_maintenance ALTER COLUMN id SET DEFAULT nextval('public.asset_maintenance_id_seq'::regclass);


--
-- Name: asset_mappings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_mappings ALTER COLUMN id SET DEFAULT nextval('public.asset_mappings_id_seq'::regclass);


--
-- Name: asset_registry id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_registry ALTER COLUMN id SET DEFAULT nextval('public.asset_registry_id_seq'::regclass);


--
-- Name: assigned_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assigned_services ALTER COLUMN id SET DEFAULT nextval('public.assigned_services_id_seq'::regclass);


--
-- Name: attendances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances ALTER COLUMN id SET DEFAULT nextval('public.attendances_id_seq'::regclass);


--
-- Name: audit_discrepancies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_discrepancies ALTER COLUMN id SET DEFAULT nextval('public.audit_discrepancies_id_seq'::regclass);


--
-- Name: booking_rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_rooms ALTER COLUMN id SET DEFAULT nextval('public.booking_rooms_id_seq'::regclass);


--
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);


--
-- Name: check_availability id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_availability ALTER COLUMN id SET DEFAULT nextval('public.check_availability_id_seq'::regclass);


--
-- Name: checklist_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_executions ALTER COLUMN id SET DEFAULT nextval('public.checklist_executions_id_seq'::regclass);


--
-- Name: checklist_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_items ALTER COLUMN id SET DEFAULT nextval('public.checklist_items_id_seq'::regclass);


--
-- Name: checklist_responses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_responses ALTER COLUMN id SET DEFAULT nextval('public.checklist_responses_id_seq'::regclass);


--
-- Name: checklists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklists ALTER COLUMN id SET DEFAULT nextval('public.checklists_id_seq'::regclass);


--
-- Name: checkout_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_payments ALTER COLUMN id SET DEFAULT nextval('public.checkout_payments_id_seq'::regclass);


--
-- Name: checkout_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_requests ALTER COLUMN id SET DEFAULT nextval('public.checkout_requests_id_seq'::regclass);


--
-- Name: checkout_verifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_verifications ALTER COLUMN id SET DEFAULT nextval('public.checkout_verifications_id_seq'::regclass);


--
-- Name: checkouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts ALTER COLUMN id SET DEFAULT nextval('public.checkouts_id_seq'::regclass);


--
-- Name: consumable_usage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumable_usage ALTER COLUMN id SET DEFAULT nextval('public.consumable_usage_id_seq'::regclass);


--
-- Name: cost_centers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_centers ALTER COLUMN id SET DEFAULT nextval('public.cost_centers_id_seq'::regclass);


--
-- Name: damage_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_reports ALTER COLUMN id SET DEFAULT nextval('public.damage_reports_id_seq'::regclass);


--
-- Name: employee_inventory_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_inventory_assignments ALTER COLUMN id SET DEFAULT nextval('public.employee_inventory_assignments_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: eod_audit_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eod_audit_items ALTER COLUMN id SET DEFAULT nextval('public.eod_audit_items_id_seq'::regclass);


--
-- Name: eod_audits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eod_audits ALTER COLUMN id SET DEFAULT nextval('public.eod_audits_id_seq'::regclass);


--
-- Name: expenses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);


--
-- Name: expiry_alerts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expiry_alerts ALTER COLUMN id SET DEFAULT nextval('public.expiry_alerts_id_seq'::regclass);


--
-- Name: fire_safety_equipment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_equipment ALTER COLUMN id SET DEFAULT nextval('public.fire_safety_equipment_id_seq'::regclass);


--
-- Name: fire_safety_incidents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_incidents ALTER COLUMN id SET DEFAULT nextval('public.fire_safety_incidents_id_seq'::regclass);


--
-- Name: fire_safety_inspections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_inspections ALTER COLUMN id SET DEFAULT nextval('public.fire_safety_inspections_id_seq'::regclass);


--
-- Name: fire_safety_maintenance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_maintenance ALTER COLUMN id SET DEFAULT nextval('public.fire_safety_maintenance_id_seq'::regclass);


--
-- Name: first_aid_kit_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_aid_kit_items ALTER COLUMN id SET DEFAULT nextval('public.first_aid_kit_items_id_seq'::regclass);


--
-- Name: first_aid_kits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_aid_kits ALTER COLUMN id SET DEFAULT nextval('public.first_aid_kits_id_seq'::regclass);


--
-- Name: food_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_categories ALTER COLUMN id SET DEFAULT nextval('public.food_categories_id_seq'::regclass);


--
-- Name: food_item_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_item_images ALTER COLUMN id SET DEFAULT nextval('public.food_item_images_id_seq'::regclass);


--
-- Name: food_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_items ALTER COLUMN id SET DEFAULT nextval('public.food_items_id_seq'::regclass);


--
-- Name: food_order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_order_items ALTER COLUMN id SET DEFAULT nextval('public.food_order_items_id_seq'::regclass);


--
-- Name: food_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_orders ALTER COLUMN id SET DEFAULT nextval('public.food_orders_id_seq'::regclass);


--
-- Name: gallery id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gallery ALTER COLUMN id SET DEFAULT nextval('public.gallery_id_seq'::regclass);


--
-- Name: goods_received_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goods_received_notes ALTER COLUMN id SET DEFAULT nextval('public.goods_received_notes_id_seq'::regclass);


--
-- Name: grn_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items ALTER COLUMN id SET DEFAULT nextval('public.grn_items_id_seq'::regclass);


--
-- Name: guest_suggestions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_suggestions ALTER COLUMN id SET DEFAULT nextval('public.guest_suggestions_id_seq'::regclass);


--
-- Name: header_banner id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.header_banner ALTER COLUMN id SET DEFAULT nextval('public.header_banner_id_seq'::regclass);


--
-- Name: indent_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indent_items ALTER COLUMN id SET DEFAULT nextval('public.indent_items_id_seq'::regclass);


--
-- Name: indents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indents ALTER COLUMN id SET DEFAULT nextval('public.indents_id_seq'::regclass);


--
-- Name: inventory_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_categories ALTER COLUMN id SET DEFAULT nextval('public.inventory_categories_id_seq'::regclass);


--
-- Name: inventory_expenses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_expenses ALTER COLUMN id SET DEFAULT nextval('public.inventory_expenses_id_seq'::regclass);


--
-- Name: inventory_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items ALTER COLUMN id SET DEFAULT nextval('public.inventory_items_id_seq'::regclass);


--
-- Name: inventory_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions ALTER COLUMN id SET DEFAULT nextval('public.inventory_transactions_id_seq'::regclass);


--
-- Name: journal_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries ALTER COLUMN id SET DEFAULT nextval('public.journal_entries_id_seq'::regclass);


--
-- Name: journal_entry_lines id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entry_lines ALTER COLUMN id SET DEFAULT nextval('public.journal_entry_lines_id_seq'::regclass);


--
-- Name: key_management id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_management ALTER COLUMN id SET DEFAULT nextval('public.key_management_id_seq'::regclass);


--
-- Name: key_movements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_movements ALTER COLUMN id SET DEFAULT nextval('public.key_movements_id_seq'::regclass);


--
-- Name: laundry_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.laundry_services ALTER COLUMN id SET DEFAULT nextval('public.laundry_services_id_seq'::regclass);


--
-- Name: leaves id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaves ALTER COLUMN id SET DEFAULT nextval('public.leaves_id_seq'::regclass);


--
-- Name: legal_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_documents ALTER COLUMN id SET DEFAULT nextval('public.legal_documents_id_seq'::regclass);


--
-- Name: linen_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_items ALTER COLUMN id SET DEFAULT nextval('public.linen_items_id_seq'::regclass);


--
-- Name: linen_movements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_movements ALTER COLUMN id SET DEFAULT nextval('public.linen_movements_id_seq'::regclass);


--
-- Name: linen_stocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_stocks ALTER COLUMN id SET DEFAULT nextval('public.linen_stocks_id_seq'::regclass);


--
-- Name: linen_wash_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_wash_logs ALTER COLUMN id SET DEFAULT nextval('public.linen_wash_logs_id_seq'::regclass);


--
-- Name: location_stocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_stocks ALTER COLUMN id SET DEFAULT nextval('public.location_stocks_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: lost_found id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lost_found ALTER COLUMN id SET DEFAULT nextval('public.lost_found_id_seq'::regclass);


--
-- Name: maintenance_tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets ALTER COLUMN id SET DEFAULT nextval('public.maintenance_tickets_id_seq'::regclass);


--
-- Name: nearby_attraction_banners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nearby_attraction_banners ALTER COLUMN id SET DEFAULT nextval('public.nearby_attraction_banners_id_seq'::regclass);


--
-- Name: nearby_attractions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nearby_attractions ALTER COLUMN id SET DEFAULT nextval('public.nearby_attractions_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: office_inventory_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_inventory_items ALTER COLUMN id SET DEFAULT nextval('public.office_inventory_items_id_seq'::regclass);


--
-- Name: office_requisitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_requisitions ALTER COLUMN id SET DEFAULT nextval('public.office_requisitions_id_seq'::regclass);


--
-- Name: outlet_stocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outlet_stocks ALTER COLUMN id SET DEFAULT nextval('public.outlet_stocks_id_seq'::regclass);


--
-- Name: outlets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outlets ALTER COLUMN id SET DEFAULT nextval('public.outlets_id_seq'::regclass);


--
-- Name: package_booking_rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_booking_rooms ALTER COLUMN id SET DEFAULT nextval('public.package_booking_rooms_id_seq'::regclass);


--
-- Name: package_bookings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_bookings ALTER COLUMN id SET DEFAULT nextval('public.package_bookings_id_seq'::regclass);


--
-- Name: package_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_images ALTER COLUMN id SET DEFAULT nextval('public.package_images_id_seq'::regclass);


--
-- Name: packages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages ALTER COLUMN id SET DEFAULT nextval('public.packages_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: perishable_batches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perishable_batches ALTER COLUMN id SET DEFAULT nextval('public.perishable_batches_id_seq'::regclass);


--
-- Name: plan_weddings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_weddings ALTER COLUMN id SET DEFAULT nextval('public.plan_weddings_id_seq'::regclass);


--
-- Name: po_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.po_items ALTER COLUMN id SET DEFAULT nextval('public.po_items_id_seq'::regclass);


--
-- Name: purchase_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_details ALTER COLUMN id SET DEFAULT nextval('public.purchase_details_id_seq'::regclass);


--
-- Name: purchase_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entries ALTER COLUMN id SET DEFAULT nextval('public.purchase_entries_id_seq'::regclass);


--
-- Name: purchase_entry_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entry_items ALTER COLUMN id SET DEFAULT nextval('public.purchase_entry_items_id_seq'::regclass);


--
-- Name: purchase_masters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_masters ALTER COLUMN id SET DEFAULT nextval('public.purchase_masters_id_seq'::regclass);


--
-- Name: purchase_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders ALTER COLUMN id SET DEFAULT nextval('public.purchase_orders_id_seq'::regclass);


--
-- Name: recipe_ingredients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients ALTER COLUMN id SET DEFAULT nextval('public.recipe_ingredients_id_seq'::regclass);


--
-- Name: recipes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipes ALTER COLUMN id SET DEFAULT nextval('public.recipes_id_seq'::regclass);


--
-- Name: resort_info id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resort_info ALTER COLUMN id SET DEFAULT nextval('public.resort_info_id_seq'::regclass);


--
-- Name: restock_alerts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restock_alerts ALTER COLUMN id SET DEFAULT nextval('public.restock_alerts_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: room_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_assets ALTER COLUMN id SET DEFAULT nextval('public.room_assets_id_seq'::regclass);


--
-- Name: room_consumable_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_consumable_assignments ALTER COLUMN id SET DEFAULT nextval('public.room_consumable_assignments_id_seq'::regclass);


--
-- Name: room_consumable_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_consumable_items ALTER COLUMN id SET DEFAULT nextval('public.room_consumable_items_id_seq'::regclass);


--
-- Name: room_inventory_audits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_audits ALTER COLUMN id SET DEFAULT nextval('public.room_inventory_audits_id_seq'::regclass);


--
-- Name: room_inventory_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_items ALTER COLUMN id SET DEFAULT nextval('public.room_inventory_items_id_seq'::regclass);


--
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- Name: security_equipment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_equipment ALTER COLUMN id SET DEFAULT nextval('public.security_equipment_id_seq'::regclass);


--
-- Name: security_maintenance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_maintenance ALTER COLUMN id SET DEFAULT nextval('public.security_maintenance_id_seq'::regclass);


--
-- Name: security_uniforms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_uniforms ALTER COLUMN id SET DEFAULT nextval('public.security_uniforms_id_seq'::regclass);


--
-- Name: service_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_images ALTER COLUMN id SET DEFAULT nextval('public.service_images_id_seq'::regclass);


--
-- Name: service_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_requests ALTER COLUMN id SET DEFAULT nextval('public.service_requests_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- Name: signature_experiences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signature_experiences ALTER COLUMN id SET DEFAULT nextval('public.signature_experiences_id_seq'::regclass);


--
-- Name: stock_issue_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issue_details ALTER COLUMN id SET DEFAULT nextval('public.stock_issue_details_id_seq'::regclass);


--
-- Name: stock_issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issues ALTER COLUMN id SET DEFAULT nextval('public.stock_issues_id_seq'::regclass);


--
-- Name: stock_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_levels ALTER COLUMN id SET DEFAULT nextval('public.stock_levels_id_seq'::regclass);


--
-- Name: stock_movements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements ALTER COLUMN id SET DEFAULT nextval('public.stock_movements_id_seq'::regclass);


--
-- Name: stock_requisition_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_requisition_details ALTER COLUMN id SET DEFAULT nextval('public.stock_requisition_details_id_seq'::regclass);


--
-- Name: stock_requisitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_requisitions ALTER COLUMN id SET DEFAULT nextval('public.stock_requisitions_id_seq'::regclass);


--
-- Name: stock_usage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_usage ALTER COLUMN id SET DEFAULT nextval('public.stock_usage_id_seq'::regclass);


--
-- Name: system_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_settings ALTER COLUMN id SET DEFAULT nextval('public.system_settings_id_seq'::regclass);


--
-- Name: units_of_measurement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_of_measurement ALTER COLUMN id SET DEFAULT nextval('public.units_of_measurement_id_seq'::regclass);


--
-- Name: uom_conversions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uom_conversions ALTER COLUMN id SET DEFAULT nextval('public.uom_conversions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vendor_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_items ALTER COLUMN id SET DEFAULT nextval('public.vendor_items_id_seq'::regclass);


--
-- Name: vendor_performance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_performance ALTER COLUMN id SET DEFAULT nextval('public.vendor_performance_id_seq'::regclass);


--
-- Name: vendors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors ALTER COLUMN id SET DEFAULT nextval('public.vendors_id_seq'::regclass);


--
-- Name: vouchers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vouchers ALTER COLUMN id SET DEFAULT nextval('public.vouchers_id_seq'::regclass);


--
-- Name: wastage_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wastage_logs ALTER COLUMN id SET DEFAULT nextval('public.wastage_logs_id_seq'::regclass);


--
-- Name: waste_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waste_logs ALTER COLUMN id SET DEFAULT nextval('public.waste_logs_id_seq'::regclass);


--
-- Name: work_order_part_issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_part_issues ALTER COLUMN id SET DEFAULT nextval('public.work_order_part_issues_id_seq'::regclass);


--
-- Name: work_order_parts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_parts ALTER COLUMN id SET DEFAULT nextval('public.work_order_parts_id_seq'::regclass);


--
-- Name: work_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders ALTER COLUMN id SET DEFAULT nextval('public.work_orders_id_seq'::regclass);


--
-- Name: working_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.working_logs ALTER COLUMN id SET DEFAULT nextval('public.working_logs_id_seq'::regclass);


--
-- Data for Name: account_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.account_groups (id, name, account_type, description, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: account_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.account_ledgers (id, name, code, group_id, module, description, opening_balance, balance_type, is_active, tax_type, tax_rate, bank_name, account_number, ifsc_code, branch_name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
a1a1bf16ff4a
\.


--
-- Data for Name: approval_matrices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.approval_matrices (id, department_id, approval_type, min_amount, max_amount, level_1_approver_role, level_2_approver_role, level_3_approver_role, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: approval_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.approval_requests (id, request_type, reference_id, reference_type, requested_by, amount, current_level, status, level_1_approver, level_1_status, level_1_date, level_2_approver, level_2_status, level_2_date, level_3_approver, level_3_status, level_3_date, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: asset_inspections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asset_inspections (id, asset_id, inspection_date, inspected_by, status, damage_description, charge_to_guest, charge_amount, notes) FROM stdin;
\.


--
-- Data for Name: asset_maintenance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asset_maintenance (id, asset_id, maintenance_type, scheduled_date, completed_date, service_provider, cost, performed_by, notes, next_service_due, created_at) FROM stdin;
\.


--
-- Data for Name: asset_mappings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asset_mappings (id, item_id, location_id, serial_number, assigned_date, assigned_by, notes, is_active, unassigned_date, quantity) FROM stdin;
4	21	5	\N	2026-01-06 19:11:24.228301	1	\N	t	\N	1
5	22	5	\N	2026-01-06 19:11:24.346125	1	\N	t	\N	1
6	22	6	\N	2026-01-06 19:14:20.073217	1	\N	t	\N	1
7	31	6	\N	2026-01-06 19:14:20.176639	1	\N	t	\N	1
\.


--
-- Data for Name: asset_registry; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asset_registry (id, asset_tag_id, item_id, serial_number, current_location_id, status, purchase_date, warranty_expiry, last_maintenance_date, next_maintenance_due, purchase_master_id, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: assigned_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assigned_services (id, service_id, employee_id, room_id, assigned_at, status, billing_status, last_used_at, override_charges) FROM stdin;
\.


--
-- Data for Name: attendances; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attendances (id, employee_id, date, status) FROM stdin;
\.


--
-- Data for Name: audit_discrepancies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_discrepancies (id, audit_id, item_id, location_id, system_quantity, physical_quantity, discrepancy, uom, resolved_by, resolved_at, notes, created_at) FROM stdin;
\.


--
-- Data for Name: booking_rooms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.booking_rooms (id, booking_id, room_id) FROM stdin;
4	4	1
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookings (id, status, guest_name, guest_mobile, guest_email, check_in, check_out, adults, children, id_card_image_url, guest_photo_url, user_id, total_amount, advance_deposit, checked_in_at) FROM stdin;
4	checked_out	alphi	684555855	goohgdw@gmail.com	2026-01-07	2026-01-08	2	0	id_4_2eb492906c7b45e384fcbb7b83ac9bc7.jpg	guest_4_3c48647e3f85485d804aaf06e17f580c.jpg	1	0	0	2026-01-07 12:32:16.462662
\.


--
-- Data for Name: check_availability; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.check_availability (id, name, email, phone, check_in, check_out, guests, is_active) FROM stdin;
\.


--
-- Data for Name: checklist_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checklist_executions (id, checklist_id, room_id, location_id, executed_by, executed_at, status, completed_at, notes) FROM stdin;
\.


--
-- Data for Name: checklist_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checklist_items (id, checklist_id, item_text, item_type, is_required, order_index) FROM stdin;
\.


--
-- Data for Name: checklist_responses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checklist_responses (id, execution_id, item_id, response, status, notes, responded_by, responded_at) FROM stdin;
\.


--
-- Data for Name: checklists; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checklists (id, name, category, module_type, description, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: checkout_payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checkout_payments (id, checkout_id, payment_method, amount, transaction_id, notes, created_at) FROM stdin;
3	3	Card	3547.4	\N	Single payment method	2026-01-07 18:21:06.433482+05:30
\.


--
-- Data for Name: checkout_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checkout_requests (id, booking_id, package_booking_id, room_number, guest_name, status, requested_by, requested_at, inventory_checked, inventory_checked_by, inventory_checked_at, inventory_notes, checkout_id, created_at, updated_at, employee_id, completed_at, inventory_data) FROM stdin;
3	4	\N	101	alphi	completed	harry	2026-01-07 18:15:23.660226+05:30	t	harry	2026-01-07 12:49:49.734364		\N	2026-01-07 18:15:23.660226+05:30	2026-01-07 18:19:49.721973+05:30	1	2026-01-07 12:49:49.846365	[{"item_id": 8, "used_qty": 2.0, "missing_qty": 0.0, "damage_qty": 0.0, "return_location_id": null, "item_name": "Mineral Water (1L)", "item_code": "ITM-4601"}, {"item_id": 9, "used_qty": 1.0, "missing_qty": 0.0, "damage_qty": 0.0, "return_location_id": null, "item_name": "Soda Cans", "item_code": "ITM-8595"}, {"item_id": 24, "used_qty": 0.0, "missing_qty": 0.0, "damage_qty": 1.0, "return_location_id": null, "item_name": "3-Pin Plug", "item_code": "ITM-5050", "damage_charge": 60.0, "unit_price": 60.0}, {"item_id": 21, "used_qty": 0.0, "missing_qty": 0.0, "damage_qty": 0.0, "return_location_id": null, "item_name": "LED Bulb 9W", "item_code": "ITM-3497"}, {"item_id": 21, "used_qty": 0.0, "missing_qty": 0.0, "damage_qty": 0.0, "return_location_id": null, "item_name": "LED Bulb 9W", "item_code": "ITM-3497"}, {"item_id": 22, "used_qty": 0.0, "missing_qty": 0.0, "damage_qty": 0.0, "return_location_id": null, "item_name": "Tube Light 20W", "item_code": "ITM-8061"}, {"asset_registry_id": null, "item_id": 22, "item_name": "Tube Light 20W", "replacement_cost": 150.0, "notes": "", "missing_item_charge": 150.0, "unit_price": 150.0, "missing_qty": 1, "is_fixed_asset": true}]
\.


--
-- Data for Name: checkout_verifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checkout_verifications (id, checkout_id, room_number, housekeeping_status, housekeeping_notes, housekeeping_approved_by, housekeeping_approved_at, consumables_audit_data, consumables_total_charge, asset_damages, asset_damage_total, key_card_returned, key_card_fee, created_at, checkout_request_id) FROM stdin;
2	3	101	pending	\N	\N	\N	{"8": {"actual": 2.0, "issued": 0.0, "limit": 0, "charge": 0.0, "is_rentable": false, "missing": 0.0}, "9": {"actual": 1.0, "issued": 0.0, "limit": 0, "charge": 0.0, "is_rentable": false, "missing": 0.0}, "24": {"actual": 0.0, "issued": 0.0, "limit": 0, "charge": 0.0, "is_rentable": false, "missing": 0.0}, "21": {"actual": 0.0, "issued": 0.0, "limit": 0, "charge": 0.0, "is_rentable": false, "missing": 0.0}, "22": {"actual": 0.0, "issued": 0.0, "limit": 0, "charge": 0.0, "is_rentable": false, "missing": 0.0}}	0	[{"item_name": "Tube Light 20W", "replacement_cost": 150.0, "notes": ""}]	150	t	0	2026-01-07 18:21:06.433482+05:30	\N
\.


--
-- Data for Name: checkouts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checkouts (id, room_total, food_total, service_total, package_total, tax_amount, discount_amount, grand_total, guest_name, room_number, created_at, checkout_date, payment_method, booking_id, package_booking_id, payment_status, late_checkout_fee, consumables_charges, asset_damage_charges, key_card_fee, advance_deposit, tips_gratuity, guest_gstin, is_b2b, invoice_number, invoice_pdf_path, gate_pass_path, feedback_sent, bill_details) FROM stdin;
3	3000	0	0	0	197.4	0	3547.4	alphi	101	2026-01-07 18:21:06.433482+05:30	2026-01-08 00:00:00	Card	4	\N	Paid	0	0	0	0	0	0	\N	f	INV-2026-000001	\N	\N	f	{"generated_at": "2026-01-07T18:21:06.747175", "charges_breakdown": {"room_charges": 3000.0, "food_charges": 0.0, "service_charges": 0.0, "package_charges": 0.0, "consumables_charges": 120.0, "inventory_charges": 80.0, "asset_damage_charges": 150.0, "key_card_fee": 0.0, "late_checkout_fee": 0.0, "advance_deposit": 0.0, "tips_gratuity": 0.0, "room_gst": 150.0, "food_gst": 0.0, "service_gst": 0.0, "package_gst": 0.0, "consumables_gst": 6.0, "inventory_gst": 14.399999999999999, "asset_damage_gst": 27.0, "total_gst": 197.4, "food_items": [], "service_items": [], "consumables_items": [{"item_id": 8, "item_name": "Mineral Water (1L)", "actual_consumed": 2.0, "complimentary_limit": 2.0, "charge_per_unit": 40.0, "total_charge": 0}, {"item_id": 9, "item_name": "Soda Cans", "actual_consumed": 1.0, "complimentary_limit": 0.0, "charge_per_unit": 60.0, "total_charge": 60.0}, {"item_id": 24, "item_name": "3-Pin Plug (Missing/Damaged)", "actual_consumed": 1.0, "complimentary_limit": 0, "charge_per_unit": 60.0, "total_charge": 60.0}], "asset_damages": [{"item_name": "Tube Light 20W", "replacement_cost": 150.0, "notes": "Damaged: 0.0, Missing: 1.0"}], "inventory_usage": [{"date": "2026-01-07T18:11:20", "item_name": "Mineral Water (1L)", "category": "Restaurant - Beverages", "quantity": 2.0, "unit": "bottle", "cost": 80.0, "room_number": "101", "is_payable": false, "is_paid": false, "rental_price": null, "is_damaged": false, "damage_notes": null}, {"date": "2026-01-07T18:11:20", "item_name": "Soda Cans", "category": "Restaurant - Beverages", "quantity": 2.0, "unit": "can", "cost": 120.0, "room_number": "101", "is_payable": false, "is_paid": false, "rental_price": null, "is_damaged": false, "damage_notes": null}, {"date": "2026-01-07T18:15:01.733000", "item_name": "3-Pin Plug", "category": "Maintenance - Electrical", "quantity": 1.0, "unit": "pcs", "cost": 60.0, "room_number": "101", "is_payable": false, "is_paid": false, "rental_price": 30.0, "is_damaged": false, "damage_notes": null, "rental_charge": 30.0, "is_rental": true}, {"date": "2026-01-07T18:15:02.027000", "item_name": "LED Bulb 9W", "category": "Maintenance - Electrical", "quantity": 1.0, "unit": "pcs", "cost": 50.0, "room_number": "101", "is_payable": false, "is_paid": false, "rental_price": 50.0, "is_damaged": false, "damage_notes": null, "rental_charge": 50.0, "is_rental": true}], "total_due": 3350.0}, "consumables_audit": {"charges": 0.0, "gst": 0.0, "items": [{"item_id": 8, "item_name": "Mineral Water (1L)", "actual_consumed": 2.0, "complimentary_limit": 2.0, "charge_per_unit": 40.0, "total_charge": 0}, {"item_id": 9, "item_name": "Soda Cans", "actual_consumed": 1.0, "complimentary_limit": 0.0, "charge_per_unit": 60.0, "total_charge": 60.0}, {"item_id": 24, "item_name": "3-Pin Plug (Missing/Damaged)", "actual_consumed": 1.0, "complimentary_limit": 0, "charge_per_unit": 60.0, "total_charge": 60.0}]}, "asset_damages": {"charges": 0.0, "gst": 0.0, "items": [{"item_name": "Tube Light 20W", "replacement_cost": 150.0, "notes": "Damaged: 0.0, Missing: 1.0"}]}, "inventory_usage": [{"date": "2026-01-07T18:11:20", "item_name": "Mineral Water (1L)", "category": "Restaurant - Beverages", "quantity": 2.0, "unit": "bottle", "cost": 80.0, "room_number": "101", "is_payable": false, "is_paid": false, "rental_price": null, "is_damaged": false, "damage_notes": null}, {"date": "2026-01-07T18:11:20", "item_name": "Soda Cans", "category": "Restaurant - Beverages", "quantity": 2.0, "unit": "can", "cost": 120.0, "room_number": "101", "is_payable": false, "is_paid": false, "rental_price": null, "is_damaged": false, "damage_notes": null}, {"date": "2026-01-07T18:15:01.733000", "item_name": "3-Pin Plug", "category": "Maintenance - Electrical", "quantity": 1.0, "unit": "pcs", "cost": 60.0, "room_number": "101", "is_payable": false, "is_paid": false, "rental_price": 30.0, "is_damaged": false, "damage_notes": null, "rental_charge": 30.0, "is_rental": true}, {"date": "2026-01-07T18:15:02.027000", "item_name": "LED Bulb 9W", "category": "Maintenance - Electrical", "quantity": 1.0, "unit": "pcs", "cost": 50.0, "room_number": "101", "is_payable": false, "is_paid": false, "rental_price": 50.0, "is_damaged": false, "damage_notes": null, "rental_charge": 50.0, "is_rental": true}]}
\.


--
-- Data for Name: consumable_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.consumable_usage (id, room_id, booking_id, item_id, quantity_used, uom, usage_type, usage_date, recorded_by, charge_amount, notes) FROM stdin;
\.


--
-- Data for Name: cost_centers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cost_centers (id, name, code, description, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: damage_reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.damage_reports (id, item_id, location_id, room_id, damage_type, description, reported_by, reported_at, status, approved_by, approved_at, resolution_action, charge_to_guest, charge_amount, notes, resolved_at) FROM stdin;
\.


--
-- Data for Name: employee_inventory_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employee_inventory_assignments (id, employee_id, assigned_service_id, item_id, quantity_assigned, quantity_used, quantity_returned, status, is_returned, assigned_at, returned_at, notes) FROM stdin;
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employees (id, name, role, salary, join_date, image_url, user_id) FROM stdin;
1	Basil Abraham	manager	1000	2026-01-06	uploads/twin-short.jpg	2
\.


--
-- Data for Name: eod_audit_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.eod_audit_items (id, audit_id, item_id, system_quantity, physical_quantity, variance, uom) FROM stdin;
\.


--
-- Data for Name: eod_audits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.eod_audits (id, audit_date, location_id, audited_by, system_stock_value, physical_stock_value, variance, variance_percentage, notes, created_at) FROM stdin;
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.expenses (id, category, amount, date, description, employee_id, image, created_at, rcm_applicable, rcm_tax_rate, nature_of_supply, original_bill_no, self_invoice_number, vendor_id, rcm_liability_date, itc_eligible, department) FROM stdin;
\.


--
-- Data for Name: expiry_alerts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.expiry_alerts (id, item_id, location_id, batch_number, expiry_date, days_until_expiry, status, created_at, acknowledged_at, acknowledged_by) FROM stdin;
\.


--
-- Data for Name: fire_safety_equipment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fire_safety_equipment (id, equipment_type, item_id, asset_id, qr_code, location_id, floor, zone, manufacturer, model, capacity, installation_date, expiry_date, last_inspection_date, next_inspection_date, last_service_date, next_service_date, status, certification_number, certification_expiry, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: fire_safety_incidents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fire_safety_incidents (id, equipment_id, incident_date, incident_type, location_id, reported_by, equipment_used, damage_assessment, action_taken, refill_required, investigation_report, notes) FROM stdin;
\.


--
-- Data for Name: fire_safety_inspections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fire_safety_inspections (id, equipment_id, inspection_date, inspected_by, inspection_type, status, pressure_check, visual_check, functional_check, notes, next_inspection_date) FROM stdin;
\.


--
-- Data for Name: fire_safety_maintenance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fire_safety_maintenance (id, equipment_id, service_type, service_date, service_provider, cost, performed_by, test_certificate_number, next_service_due, notes) FROM stdin;
\.


--
-- Data for Name: first_aid_kit_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.first_aid_kit_items (id, kit_id, item_id, par_quantity, current_quantity, expiry_date, last_restocked) FROM stdin;
\.


--
-- Data for Name: first_aid_kits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.first_aid_kits (id, kit_number, location_id, last_checked_date, next_check_date, expiry_items_count, status, checked_by, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: food_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.food_categories (id, name, image) FROM stdin;
\.


--
-- Data for Name: food_item_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.food_item_images (id, image_url, item_id) FROM stdin;
\.


--
-- Data for Name: food_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.food_items (id, name, description, price, available, category_id) FROM stdin;
\.


--
-- Data for Name: food_order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.food_order_items (id, order_id, food_item_id, quantity) FROM stdin;
\.


--
-- Data for Name: food_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.food_orders (id, room_id, amount, assigned_employee_id, status, billing_status, created_at, order_type, delivery_request, payment_method, payment_time, gst_amount, total_with_gst, is_deleted) FROM stdin;
\.


--
-- Data for Name: gallery; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.gallery (id, image_url, caption, is_active) FROM stdin;
\.


--
-- Data for Name: goods_received_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.goods_received_notes (id, grn_number, po_id, received_by, verified_by, status, received_date, verified_date, notes) FROM stdin;
\.


--
-- Data for Name: grn_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.grn_items (id, grn_id, po_item_id, item_id, quantity, uom, expiry_date, batch_number, unit_price, location_id, barcode_generated) FROM stdin;
\.


--
-- Data for Name: guest_suggestions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.guest_suggestions (id, guest_name, contact_info, suggestion, status, created_at) FROM stdin;
\.


--
-- Data for Name: header_banner; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.header_banner (id, title, subtitle, image_url, is_active) FROM stdin;
\.


--
-- Data for Name: indent_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.indent_items (id, indent_id, item_id, requested_quantity, approved_quantity, issued_quantity, uom, notes) FROM stdin;
\.


--
-- Data for Name: indents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.indents (id, indent_number, requested_from_location_id, requested_to_location_id, status, requested_by, approved_by, requested_date, approved_date, fulfilled_date, notes) FROM stdin;
\.


--
-- Data for Name: inventory_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_categories (id, name, description, is_active, created_at, updated_at, parent_department, gst_tax_rate, is_perishable, is_asset_fixed, is_sellable, track_laundry, allow_partial_usage, consumable_instant, classification, hsn_sac_code, default_gst_rate, cess_percentage, itc_eligibility, is_capital_good) FROM stdin;
1	Kitchen Raw Materials		t	2026-01-06 06:25:11.921796	\N	Restaurant	12	t	f	f	f	t	t	Goods	12345	12	0	Eligible	f
2	Linen & Bedding		t	2026-01-06 06:26:00.062024	\N	Hotel	12	f	t	f	t	f	f	Goods	1234	5	0	Eligible	t
3	Electronics		t	2026-01-06 06:27:38.741686	\N	Facility	18	f	t	f	f	f	f	Goods	12345	12	0	Eligible	f
4	Restaurant - Raw Materials	\N	t	2026-01-06 06:35:12.08033	\N	Restaurant	0	f	f	f	f	f	f	\N	\N	0	0	Eligible	f
5	Restaurant - Beverages	\N	t	2026-01-06 06:35:12.2609	\N	Restaurant	0	f	f	f	f	f	f	\N	\N	0	0	Eligible	f
6	Housekeeping - Linen	\N	t	2026-01-06 06:35:12.347782	\N	Housekeeping	0	f	f	f	t	f	f	\N	\N	0	0	Eligible	f
7	Housekeeping - Toiletries	\N	t	2026-01-06 06:35:12.433536	\N	Housekeeping	0	f	f	f	f	f	f	\N	\N	0	0	Eligible	f
8	Maintenance - Electrical	\N	t	2026-01-06 06:35:12.517053	\N	Maintenance	0	f	t	f	f	f	f	\N	\N	0	0	Eligible	f
9	Office Supplies	\N	t	2026-01-06 06:35:12.617597	\N	Front Office	0	f	f	f	f	f	f	\N	\N	0	0	Eligible	f
10	Room Electronics & Furniture	\N	t	2026-01-06 07:36:14.23872	\N	Housekeeping	0	f	t	f	f	f	f	\N	\N	0	0	Eligible	f
\.


--
-- Data for Name: inventory_expenses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_expenses (id, item_id, cost_center_id, quantity, uom, unit_cost, total_cost, issued_to, issued_by, issued_date, notes) FROM stdin;
\.


--
-- Data for Name: inventory_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_items (id, name, description, category_id, sku, barcode, base_uom_id, unit_price, selling_price, track_expiry, track_serial, track_batch, min_stock_level, max_stock_level, is_active, created_at, updated_at, hsn_code, gst_rate, item_code, sub_category, image_path, location, track_serial_number, is_sellable_to_guest, track_laundry_cycle, is_asset_fixed, maintenance_schedule_days, complimentary_limit, ingredient_yield_percentage, preferred_vendor_id, vendor_item_code, lead_time_days, is_perishable, unit, current_stock) FROM stdin;
1	Basmati Rice	\N	4	\N	\N	\N	1000	\N	\N	\N	\N	50	\N	t	2026-01-06 06:35:12.101306	2026-01-07 12:13:27.37677	\N	0	ITM-2614	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	kg	20
2	Cooking Oil (Sunflower)	\N	4	\N	\N	\N	300	\N	\N	\N	\N	20	\N	t	2026-01-06 06:35:12.174315	2026-01-07 12:13:27.376798	\N	0	ITM-7764	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	liter	20
3	Chicken Breast (Frozen)	\N	4	\N	\N	\N	180	\N	\N	\N	\N	10	\N	t	2026-01-06 06:35:12.196802	2026-01-07 12:13:27.376813	\N	0	ITM-5655	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	t	kg	20
4	Wheat Flour (Atta)	\N	4	\N	\N	\N	49	\N	\N	\N	\N	30	\N	t	2026-01-06 06:35:12.217804	2026-01-07 12:13:27.37683	\N	0	ITM-3306	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	kg	20
5	Sugar	\N	4	\N	\N	\N	60	\N	\N	\N	\N	25	\N	t	2026-01-06 06:35:12.234819	2026-01-07 12:13:27.376844	\N	0	ITM-8262	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	kg	20
6	Coffee Beans	\N	5	\N	\N	\N	200	\N	\N	\N	\N	5	\N	t	2026-01-06 06:35:12.270053	2026-01-07 12:13:27.376857	\N	0	ITM-9850	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	kg	20
16	Soap Bar (Small)	\N	7	\N	\N	\N	20	\N	\N	\N	\N	200	\N	t	2026-01-06 06:35:12.442206	2026-01-07 12:18:20.217349	\N	0	ITM-2768	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
17	Shampoo Bottle (30ml)	\N	7	\N	\N	\N	10	\N	\N	\N	\N	200	\N	t	2026-01-06 06:35:12.459086	2026-01-07 12:18:20.217373	\N	0	ITM-4613	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	bottle	20
18	Toothpaste Kit	\N	7	\N	\N	\N	30	\N	\N	\N	\N	100	\N	t	2026-01-06 06:35:12.474705	2026-01-07 12:18:20.217388	\N	0	ITM-9757	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	kit	20
19	Toilet Paper Roll	\N	7	\N	\N	\N	100	\N	\N	\N	\N	100	\N	t	2026-01-06 06:35:12.490107	2026-01-07 12:18:20.217402	\N	0	ITM-3033	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	roll	20
20	Floor Cleaner Liquid	\N	7	\N	\N	\N	500	\N	\N	\N	\N	10	\N	t	2026-01-06 06:35:12.505302	2026-01-07 12:18:20.217416	\N	0	ITM-1167	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	liter	20
21	LED Bulb 9W	\N	8	\N	\N	\N	50	\N	\N	\N	\N	20	\N	t	2026-01-06 06:35:12.525127	2026-01-07 12:18:20.217429	\N	0	ITM-3497	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
22	Tube Light 20W	\N	8	\N	\N	\N	150	\N	\N	\N	\N	15	\N	t	2026-01-06 06:35:12.540017	2026-01-07 12:18:20.217442	\N	0	ITM-8061	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
23	Extension Cord	\N	8	\N	\N	\N	300	\N	\N	\N	\N	5	\N	t	2026-01-06 06:35:12.560693	2026-01-07 12:18:20.217456	\N	0	ITM-4480	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
25	Electrical Tape	\N	8	\N	\N	\N	90	\N	\N	\N	\N	10	\N	t	2026-01-06 06:35:12.601413	2026-01-07 12:18:20.217483	\N	0	ITM-9935	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	roll	20
15	Bath Robe	\N	6	\N	\N	\N	1200	\N	\N	\N	\N	20	\N	t	2026-01-06 06:35:12.421032	2026-01-06 19:08:21.346857	\N	0	ITM-2630	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	0
26	A4 Paper Ream	\N	9	\N	\N	\N	400	\N	\N	\N	\N	10	\N	t	2026-01-06 06:35:12.628634	2026-01-07 12:18:20.217497	\N	0	ITM-9123	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	ream	20
8	Mineral Water (1L)	\N	5	\N	\N	\N	10	40	\N	\N	\N	100	\N	t	2026-01-06 06:35:12.30088	2026-01-07 12:49:49.772521	\N	0	ITM-4601	\N	\N	Main Warehouse	f	t	f	f	\N	\N	\N	1	\N	\N	f	bottle	18
7	Tea Dust	\N	5	\N	\N	\N	200	\N	\N	\N	\N	5	\N	t	2026-01-06 06:35:12.283504	2026-01-07 12:13:27.376872	\N	0	ITM-9722	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	kg	20
10	Fruit Juice (1L)	\N	5	\N	\N	\N	30	\N	\N	\N	\N	20	\N	t	2026-01-06 06:35:12.333937	2026-01-07 12:13:27.376915	\N	0	ITM-9844	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pack	20
11	Bath Towel (White)	\N	6	\N	\N	\N	40	\N	\N	\N	\N	50	\N	t	2026-01-06 06:35:12.357886	2026-01-07 12:13:27.37693	\N	0	ITM-7422	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
12	Hand Towel	\N	6	\N	\N	\N	30	\N	\N	\N	\N	50	\N	t	2026-01-06 06:35:12.37363	2026-01-07 12:13:27.376944	\N	0	ITM-7155	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
13	Bed Sheet (King)	\N	6	\N	\N	\N	100	\N	\N	\N	\N	40	\N	t	2026-01-06 06:35:12.389833	2026-01-07 12:13:27.376958	\N	0	ITM-2371	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
14	Pillow Cover	\N	6	\N	\N	\N	60	\N	\N	\N	\N	80	\N	t	2026-01-06 06:35:12.405866	2026-01-07 12:13:27.376971	\N	0	ITM-7045	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
9	Soda Cans	\N	5	\N	\N	\N	39	60	\N	\N	\N	50	\N	t	2026-01-06 06:35:12.319002	2026-01-07 12:49:49.796605	\N	0	ITM-8595	\N	\N	Main Warehouse	f	t	f	f	\N	\N	\N	1	\N	\N	f	can	19
24	3-Pin Plug	\N	8	\N	\N	\N	60	\N	\N	\N	\N	30	\N	t	2026-01-06 06:35:12.58066	2026-01-07 12:49:49.796612	\N	0	ITM-5050	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	19
27	Ballpoint Pen (Blue)	\N	9	\N	\N	\N	20	\N	\N	\N	\N	5	\N	t	2026-01-06 06:35:12.650572	2026-01-07 12:18:20.217511	\N	0	ITM-2661	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	box	20
28	Stapler	\N	9	\N	\N	\N	20	\N	\N	\N	\N	2	\N	t	2026-01-06 06:35:12.674664	2026-01-07 12:21:27.256509	\N	0	ITM-4273	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
29	Notepads	\N	9	\N	\N	\N	30	\N	\N	\N	\N	50	\N	t	2026-01-06 06:35:12.698662	2026-01-07 12:21:27.256532	\N	0	ITM-9433	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	pcs	20
30	Printer Toner	\N	9	\N	\N	\N	1000	\N	\N	\N	\N	2	\N	t	2026-01-06 06:35:12.722548	2026-01-07 12:21:27.256544	\N	0	ITM-2749	\N	\N	Main Warehouse	f	f	f	f	\N	\N	\N	1	\N	\N	f	cartridge	20
31	Smart TV 43-inch	\N	10	\N	\N	\N	2000	\N	\N	\N	\N	0	\N	t	2026-01-06 07:36:14.259823	2026-01-07 12:21:27.256555	\N	0	AST-2881	\N	\N	Main Warehouse	f	f	f	t	\N	\N	\N	\N	\N	\N	f	pcs	20
32	Mini Fridge	\N	10	\N	\N	\N	3000	\N	\N	\N	\N	0	\N	t	2026-01-06 07:36:14.271239	2026-01-07 12:21:27.256567	\N	0	AST-9916	\N	\N	Main Warehouse	f	f	f	t	\N	\N	\N	\N	\N	\N	f	pcs	20
33	Electric Kettle	\N	10	\N	\N	\N	400	\N	\N	\N	\N	0	\N	t	2026-01-06 07:36:14.281524	2026-01-07 12:21:27.256578	\N	0	AST-7878	\N	\N	Main Warehouse	f	f	f	t	\N	\N	\N	\N	\N	\N	f	pcs	20
34	Hair Dryer	\N	10	\N	\N	\N	300	\N	\N	\N	\N	0	\N	t	2026-01-06 07:36:14.286953	2026-01-07 12:21:27.256588	\N	0	AST-2911	\N	\N	Main Warehouse	f	f	f	t	\N	\N	\N	\N	\N	\N	f	pcs	20
35	Safe Locker	\N	10	\N	\N	\N	7000	\N	\N	\N	\N	0	\N	t	2026-01-06 07:36:14.295544	2026-01-07 12:21:27.256599	\N	0	AST-7739	\N	\N	Main Warehouse	f	f	f	t	\N	\N	\N	\N	\N	\N	f	pcs	20
36	Study Table	\N	10	\N	\N	\N	1200	\N	\N	\N	\N	0	\N	t	2026-01-06 07:36:14.302667	2026-01-07 12:21:27.256611	\N	0	AST-2493	\N	\N	Main Warehouse	f	f	f	t	\N	\N	\N	\N	\N	\N	f	pcs	20
37	Ergonomic Chair	\N	10	\N	\N	\N	2000	\N	\N	\N	\N	0	\N	t	2026-01-06 07:36:14.310578	2026-01-07 12:21:27.256622	\N	0	AST-1114	\N	\N	Main Warehouse	f	f	f	t	\N	\N	\N	\N	\N	\N	f	pcs	20
\.


--
-- Data for Name: inventory_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_transactions (id, item_id, transaction_type, quantity, unit_price, total_amount, reference_number, purchase_master_id, notes, created_by, created_at, department) FROM stdin;
633	16	in	20	20	400	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239653	\N
634	17	in	20	10	200	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.23968	\N
635	18	in	20	30	600	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239695	\N
636	19	in	20	100	2000	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239709	\N
637	20	in	20	500	10000	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239723	\N
638	21	in	20	50	1000	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239737	\N
639	22	in	20	150	3000	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239751	\N
640	23	in	20	300	6000	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239765	\N
641	24	in	20	60	1200	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239779	\N
642	26	in	20	400	8000	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239793	\N
643	25	in	20	90	1800	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239807	\N
644	27	in	20	20	400	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239821	\N
645	28	in	19	130	2470	PO-20260107-0002	\N	Purchase received: PO-20260107-0002	1	2026-01-07 12:18:20.239835	\N
656	8	transfer_out	2	40	80	ISS-20260107-001	\N	Stock Issue: ISS-20260107-001 → Main Block - Standard Room - Extra allocation for booking BK-000004 (2 payable, 2 comp) - Source: 1	1	2026-01-07 12:41:13.575388	\N
657	8	transfer_in	2	40	80	ISS-20260107-001	\N	Stock Received: ISS-20260107-001 from 1	1	2026-01-07 12:41:13.575397	Main Block - Standard Room
658	9	transfer_out	2	60	120	ISS-20260107-001	\N	Stock Issue: ISS-20260107-001 → Main Block - Standard Room - Extra allocation for booking BK-000004 (2 payable, 2 comp) - Source: 1	1	2026-01-07 12:41:13.575402	\N
659	9	transfer_in	2	60	120	ISS-20260107-001	\N	Stock Received: ISS-20260107-001 from 1	1	2026-01-07 12:41:13.575407	Main Block - Standard Room
662	21	transfer_out	1	50	50	ISS-20260107-003	\N	Stock Issue: ISS-20260107-003 → Main Block - Standard Room - Rentable asset: LED Bulb 9W	1	2026-01-07 12:44:54.8178	\N
663	21	transfer_in	1	50	50	ISS-20260107-003	\N	Stock Received: ISS-20260107-003 from 1	1	2026-01-07 12:44:54.817829	Main Block - Standard Room
646	28	in	1	20	20	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.271012	\N
647	29	in	20	30	600	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.271036	\N
619	1	in	20	1000	20000	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412242	\N
620	2	in	20	300	6000	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412266	\N
621	3	in	20	180	3600	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412281	\N
622	4	in	20	49	980	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412295	\N
623	5	in	20	60	1200	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412308	\N
624	6	in	20	200	4000	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412321	\N
625	8	in	20	10	200	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412335	\N
626	9	in	20	39	780	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412349	\N
627	7	in	20	200	4000	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412363	\N
628	10	in	20	30	600	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412377	\N
629	11	in	20	40	800	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412391	\N
630	12	in	20	30	600	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412404	\N
631	13	in	20	100	2000	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412417	\N
632	14	in	20	60	1200	PO-20260107-0001	\N	Purchase received: PO-20260107-0001	1	2026-01-07 12:13:27.412431	\N
648	30	in	20	1000	20000	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.271049	\N
649	31	in	20	2000	40000	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.271059	\N
650	32	in	20	3000	60000	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.271069	\N
651	33	in	20	400	8000	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.27108	\N
652	34	in	20	300	6000	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.271091	\N
653	35	in	20	7000	140000	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.271102	\N
654	36	in	20	1200	24000	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.271113	\N
655	37	in	20	2000	40000	PO-20260107-0003	\N	Purchase received: PO-20260107-0003	1	2026-01-07 12:21:27.271124	\N
660	24	transfer_out	1	60	60	ISS-20260107-002	\N	Stock Issue: ISS-20260107-002 → Main Block - Standard Room - Rentable asset: 3-Pin Plug	1	2026-01-07 12:44:54.498829	\N
661	24	transfer_in	1	60	60	ISS-20260107-002	\N	Stock Received: ISS-20260107-002 from 1	1	2026-01-07 12:44:54.498879	Main Block - Standard Room
664	8	out	2	10	20	CONSUME-CHK-3	\N	Consumption at checkout - Room 101	1	2026-01-07 12:49:49.773766	\N
665	9	transfer_in	1	39	39	RET-RM101	\N	Stock return: Room 101 -> Main Warehouse (Central) (Checkout #3)	1	2026-01-07 12:49:49.77377	\N
666	9	out	1	39	39	CONSUME-CHK-3	\N	Consumption at checkout - Room 101	1	2026-01-07 12:49:49.800606	\N
667	24	waste_spoilage	1	60	60	WASTE-20260107-001	\N	Damage/Missing at checkout - Room 101	1	2026-01-07 12:49:49.853503	\N
668	21	transfer_in	1	50	50	RET-RM101	\N	Stock return: Room 101 -> Main Warehouse (Central) (Checkout #3)	1	2026-01-07 12:49:49.853508	\N
669	22	waste_spoilage	1	150	150	WASTE-20260107-002	\N	Damaged asset at checkout - Room 101	1	2026-01-07 12:49:49.853511	\N
\.


--
-- Data for Name: journal_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.journal_entries (id, entry_number, entry_date, reference_type, reference_id, description, total_amount, created_by, notes, is_reversed, reversed_entry_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: journal_entry_lines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.journal_entry_lines (id, entry_id, debit_ledger_id, credit_ledger_id, amount, description, line_number, created_at) FROM stdin;
\.


--
-- Data for Name: key_management; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.key_management (id, key_number, key_type, location_id, room_id, description, current_holder, status, issued_date, returned_date, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: key_movements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.key_movements (id, key_id, movement_type, from_user_id, to_user_id, purpose, movement_date, returned_date, notes) FROM stdin;
\.


--
-- Data for Name: laundry_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.laundry_services (id, vendor_id, name, contact_person, phone, email, rate_per_kg, rate_per_piece, turnaround_time_days, is_active, notes, created_at) FROM stdin;
\.


--
-- Data for Name: leaves; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.leaves (id, employee_id, from_date, to_date, reason, leave_type, status) FROM stdin;
\.


--
-- Data for Name: legal_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.legal_documents (id, name, document_type, file_path, uploaded_at, description) FROM stdin;
\.


--
-- Data for Name: linen_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.linen_items (id, item_id, rfid_tag, barcode, quality_grade, wash_count, max_washes, current_state, current_location_id, current_room_id, purchase_date, first_use_date, discard_date, discard_reason, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: linen_movements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.linen_movements (id, item_id, room_id, from_state, to_state, quantity, movement_date, moved_by, notes) FROM stdin;
\.


--
-- Data for Name: linen_stocks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.linen_stocks (id, item_id, location_id, state, quantity, last_updated) FROM stdin;
\.


--
-- Data for Name: linen_wash_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.linen_wash_logs (id, linen_item_id, wash_date, wash_count_after, quality_after, laundry_provider, cost, notes) FROM stdin;
\.


--
-- Data for Name: location_stocks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.location_stocks (id, location_id, item_id, quantity, last_updated) FROM stdin;
350	1	16	20	2026-01-07 12:18:20.263183
351	1	17	20	2026-01-07 12:18:20.263207
352	1	18	20	2026-01-07 12:18:20.263221
353	1	19	20	2026-01-07 12:18:20.263235
354	1	20	20	2026-01-07 12:18:20.263248
356	1	22	20	2026-01-07 12:18:20.263275
357	1	23	20	2026-01-07 12:18:20.263288
359	1	26	20	2026-01-07 12:18:20.263314
360	1	25	20	2026-01-07 12:18:20.263328
361	1	27	20	2026-01-07 12:18:20.263341
362	1	28	20	2026-01-07 12:21:27.287644
363	1	29	20	2026-01-07 12:21:27.289954
364	1	30	20	2026-01-07 12:21:27.289972
365	1	31	20	2026-01-07 12:21:27.289983
366	1	32	20	2026-01-07 12:21:27.289993
367	1	33	20	2026-01-07 12:21:27.290003
368	1	34	20	2026-01-07 12:21:27.290013
369	1	35	20	2026-01-07 12:21:27.290023
370	1	36	20	2026-01-07 12:21:27.290032
371	1	37	20	2026-01-07 12:21:27.290042
342	1	8	18	2026-01-07 12:41:13.582556
358	1	24	19	2026-01-07 12:44:54.516909
343	1	9	19	2026-01-07 12:49:49.76575
372	5	8	0	2026-01-07 12:49:49.752964
373	5	9	0	2026-01-07 12:49:49.764162
374	5	24	0	2026-01-07 12:49:49.787059
355	1	21	20	2026-01-07 12:49:49.822829
375	5	21	0	2026-01-07 12:49:49.830025
336	1	1	20	2026-01-07 12:13:27.449748
337	1	2	20	2026-01-07 12:13:27.449775
338	1	3	20	2026-01-07 12:13:27.44979
339	1	4	20	2026-01-07 12:13:27.449803
340	1	5	20	2026-01-07 12:13:27.449815
341	1	6	20	2026-01-07 12:13:27.449829
344	1	7	20	2026-01-07 12:13:27.44987
345	1	10	20	2026-01-07 12:13:27.449885
346	1	11	20	2026-01-07 12:13:27.449899
347	1	12	20	2026-01-07 12:13:27.449912
348	1	13	20	2026-01-07 12:13:27.449925
349	1	14	20	2026-01-07 12:13:27.449938
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.locations (id, name, code, location_type, parent_location_id, description, is_active, created_at, location_code, is_inventory_point, building, floor, room_area) FROM stdin;
1	Main Warehouse (Central)	\N	WAREHOUSE	\N		t	2026-01-06 06:28:29.562822	LOC-WH-1	t	main	1	1
2	Kitchen Store	\N	WAREHOUSE	\N		t	2026-01-06 06:29:19.651122	LOC-WH-001	t	kitchen	1	001
3	Housekeeping Store	\N	WAREHOUSE	\N		t	2026-01-06 06:29:41.261197	LOC-WH-3	t	Housekeeping Store	Housekeeping Store	Housekeeping Store
4	Laundry	\N	LAUNDRY	\N		t	2026-01-06 06:30:13.414172	LOC-LNDRY-4	t	Laundry	Laundry	Laundry
5	Room 101	\N	GUEST_ROOM	\N	Standard Room - Room 101	t	2026-01-06 06:50:42.43888	\N	t	Main Block	1th Floor	Standard Room
6	Room 102	\N	GUEST_ROOM	\N	Standard Room - Room 102	t	2026-01-06 06:50:42.551009	\N	t	Main Block	1th Floor	Standard Room
7	Room 103	\N	GUEST_ROOM	\N	Standard Room - Room 103	t	2026-01-06 06:50:42.591912	\N	t	Main Block	1th Floor	Standard Room
8	Room 104	\N	GUEST_ROOM	\N	Standard Room - Room 104	t	2026-01-06 06:50:42.631235	\N	t	Main Block	1th Floor	Standard Room
9	Room 105	\N	GUEST_ROOM	\N	Standard Room - Room 105	t	2026-01-06 06:50:42.672959	\N	t	Main Block	1th Floor	Standard Room
10	Room 201	\N	GUEST_ROOM	\N	Deluxe Room - Room 201	t	2026-01-06 06:50:42.714801	\N	t	Main Block	2th Floor	Deluxe Room
11	Room 202	\N	GUEST_ROOM	\N	Deluxe Room - Room 202	t	2026-01-06 06:50:42.772215	\N	t	Main Block	2th Floor	Deluxe Room
12	Room 203	\N	GUEST_ROOM	\N	Deluxe Room - Room 203	t	2026-01-06 06:50:42.828247	\N	t	Main Block	2th Floor	Deluxe Room
13	Room 204	\N	GUEST_ROOM	\N	Deluxe Room - Room 204	t	2026-01-06 06:50:42.885199	\N	t	Main Block	2th Floor	Deluxe Room
14	Room 205	\N	GUEST_ROOM	\N	Deluxe Room - Room 205	t	2026-01-06 06:50:42.942646	\N	t	Main Block	2th Floor	Deluxe Room
15	Room 301	\N	GUEST_ROOM	\N	Suite - Room 301	t	2026-01-06 06:50:42.998485	\N	t	Main Block	3th Floor	Suite
16	Room 302	\N	GUEST_ROOM	\N	Suite - Room 302	t	2026-01-06 06:50:43.071845	\N	t	Main Block	3th Floor	Suite
17	Room 303	\N	GUEST_ROOM	\N	Suite - Room 303	t	2026-01-06 06:50:43.14968	\N	t	Main Block	3th Floor	Suite
18	Room 304	\N	GUEST_ROOM	\N	Suite - Room 304	t	2026-01-06 06:50:43.232479	\N	t	Main Block	3th Floor	Suite
19	Room 305	\N	GUEST_ROOM	\N	Suite - Room 305	t	2026-01-06 06:50:43.30891	\N	t	Main Block	3th Floor	Suite
20	Room 401	\N	GUEST_ROOM	\N	Executive Suite - Room 401	t	2026-01-06 06:50:43.383373	\N	t	Main Block	4th Floor	Executive Suite
21	Room 402	\N	GUEST_ROOM	\N	Executive Suite - Room 402	t	2026-01-06 06:50:43.46523	\N	t	Main Block	4th Floor	Executive Suite
22	Room 403	\N	GUEST_ROOM	\N	Executive Suite - Room 403	t	2026-01-06 06:50:43.554679	\N	t	Main Block	4th Floor	Executive Suite
23	Room 404	\N	GUEST_ROOM	\N	Executive Suite - Room 404	t	2026-01-06 06:50:43.647107	\N	t	Main Block	4th Floor	Executive Suite
24	Room 405	\N	GUEST_ROOM	\N	Executive Suite - Room 405	t	2026-01-06 06:50:43.739133	\N	t	Main Block	4th Floor	Executive Suite
25	Room 501	\N	GUEST_ROOM	\N	Presidential Suite - Room 501	t	2026-01-06 06:50:43.826269	\N	t	Main Block	5th Floor	Presidential Suite
26	Room 502	\N	GUEST_ROOM	\N	Presidential Suite - Room 502	t	2026-01-06 06:50:43.973991	\N	t	Main Block	5th Floor	Presidential Suite
27	Room 503	\N	GUEST_ROOM	\N	Presidential Suite - Room 503	t	2026-01-06 06:50:44.145916	\N	t	Main Block	5th Floor	Presidential Suite
28	Room 504	\N	GUEST_ROOM	\N	Presidential Suite - Room 504	t	2026-01-06 06:50:44.323268	\N	t	Main Block	5th Floor	Presidential Suite
29	Room 505	\N	GUEST_ROOM	\N	Presidential Suite - Room 505	t	2026-01-06 06:50:44.496775	\N	t	Main Block	5th Floor	Presidential Suite
\.


--
-- Data for Name: lost_found; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lost_found (id, item_description, found_date, found_by, found_by_employee_id, room_number, location, status, claimed_by, claimed_date, claimed_contact, notes, image_url, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_tickets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_tickets (id, title, description, category, item_id, location_id, room_id, priority, status, reported_by, assigned_to, created_at, updated_at, resolution_notes, completed_at) FROM stdin;
\.


--
-- Data for Name: nearby_attraction_banners; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.nearby_attraction_banners (id, title, subtitle, image_url, is_active, map_link) FROM stdin;
\.


--
-- Data for Name: nearby_attractions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.nearby_attractions (id, title, description, image_url, is_active, map_link) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, type, title, message, is_read, created_at, read_at, entity_type, entity_id) FROM stdin;
\.


--
-- Data for Name: office_inventory_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.office_inventory_items (id, item_id, item_type, department_id, location_id, assigned_to, asset_tag, serial_number, purchase_date, purchase_price, warranty_expiry, amc_expiry, status, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: office_requisitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.office_requisitions (id, req_number, item_id, requested_by, department_id, quantity, uom, purpose, status, supervisor_approval, admin_approval, approved_date, issued_date, issued_by, notes, created_at) FROM stdin;
\.


--
-- Data for Name: outlet_stocks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.outlet_stocks (id, outlet_id, item_id, quantity, uom, par_level, last_updated) FROM stdin;
\.


--
-- Data for Name: outlets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.outlets (id, name, code, location_id, outlet_type, is_active, description, created_at) FROM stdin;
\.


--
-- Data for Name: package_booking_rooms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.package_booking_rooms (id, package_booking_id, room_id) FROM stdin;
\.


--
-- Data for Name: package_bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.package_bookings (id, package_id, user_id, guest_name, guest_email, guest_mobile, check_in, check_out, adults, children, id_card_image_url, guest_photo_url, status, advance_deposit, checked_in_at, food_preferences, special_requests) FROM stdin;
\.


--
-- Data for Name: package_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.package_images (id, package_id, image_url) FROM stdin;
\.


--
-- Data for Name: packages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.packages (id, title, description, price, booking_type, room_types, theme, default_adults, default_children, max_stay_days, food_included, food_timing, complimentary) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, booking_id, amount, method, status, created_at) FROM stdin;
\.


--
-- Data for Name: perishable_batches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.perishable_batches (id, item_id, location_id, batch_number, quantity, uom, expiry_date, received_date, created_at) FROM stdin;
\.


--
-- Data for Name: plan_weddings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.plan_weddings (id, title, description, image_url, is_active) FROM stdin;
\.


--
-- Data for Name: po_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.po_items (id, po_id, item_id, quantity, uom, unit_price, total_price, received_quantity) FROM stdin;
\.


--
-- Data for Name: purchase_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_details (id, purchase_master_id, item_id, hsn_code, quantity, unit, unit_price, gst_rate, cgst_amount, sgst_amount, igst_amount, discount, total_amount, notes) FROM stdin;
39	3	1	\N	20	kg	1000.00	0.00	0.00	0.00	0.00	0.00	20000.00	\N
40	3	2	\N	20	liter	300.00	0.00	0.00	0.00	0.00	0.00	6000.00	\N
41	3	3	\N	20	kg	180.00	0.00	0.00	0.00	0.00	0.00	3600.00	\N
42	3	4	\N	20	kg	49.00	0.00	0.00	0.00	0.00	0.00	980.00	\N
43	3	5	\N	20	kg	60.00	0.00	0.00	0.00	0.00	0.00	1200.00	\N
44	3	6	\N	20	kg	200.00	0.00	0.00	0.00	0.00	0.00	4000.00	\N
45	3	8	\N	20	bottle	10.00	0.00	0.00	0.00	0.00	0.00	200.00	\N
46	3	9	\N	20	can	39.00	0.00	0.00	0.00	0.00	0.00	780.00	\N
47	3	7	\N	20	kg	200.00	0.00	0.00	0.00	0.00	0.00	4000.00	\N
48	3	10	\N	20	pack	30.00	0.00	0.00	0.00	0.00	0.00	600.00	\N
49	3	11	\N	20	pcs	40.00	0.00	0.00	0.00	0.00	0.00	800.00	\N
50	3	12	\N	20	pcs	30.00	0.00	0.00	0.00	0.00	0.00	600.00	\N
51	3	13	\N	20	pcs	100.00	0.00	0.00	0.00	0.00	0.00	2000.00	\N
52	3	14	\N	20	pcs	60.00	0.00	0.00	0.00	0.00	0.00	1200.00	\N
53	4	16	\N	20	pcs	20.00	0.00	0.00	0.00	0.00	0.00	400.00	\N
54	4	17	\N	20	bottle	10.00	0.00	0.00	0.00	0.00	0.00	200.00	\N
55	4	18	\N	20	kit	30.00	0.00	0.00	0.00	0.00	0.00	600.00	\N
56	4	19	\N	20	roll	100.00	0.00	0.00	0.00	0.00	0.00	2000.00	\N
57	4	20	\N	20	liter	500.00	0.00	0.00	0.00	0.00	0.00	10000.00	\N
58	4	21	\N	20	pcs	50.00	0.00	0.00	0.00	0.00	0.00	1000.00	\N
59	4	22	\N	20	pcs	150.00	0.00	0.00	0.00	0.00	0.00	3000.00	\N
60	4	23	\N	20	pcs	300.00	0.00	0.00	0.00	0.00	0.00	6000.00	\N
61	4	24	\N	20	pcs	60.00	0.00	0.00	0.00	0.00	0.00	1200.00	\N
62	4	26	\N	20	ream	400.00	0.00	0.00	0.00	0.00	0.00	8000.00	\N
63	4	25	\N	20	roll	90.00	0.00	0.00	0.00	0.00	0.00	1800.00	\N
64	4	27	\N	20	box	20.00	0.00	0.00	0.00	0.00	0.00	400.00	\N
65	4	28	\N	19	pcs	130.00	0.00	0.00	0.00	0.00	0.00	2470.00	\N
66	5	28	\N	1	pcs	20.00	0.00	0.00	0.00	0.00	0.00	20.00	\N
67	5	29	\N	20	pcs	30.00	0.00	0.00	0.00	0.00	0.00	600.00	\N
68	5	30	\N	20	cartridge	1000.00	0.00	0.00	0.00	0.00	0.00	20000.00	\N
69	5	31	\N	20	pcs	2000.00	0.00	0.00	0.00	0.00	0.00	40000.00	\N
70	5	32	\N	20	pcs	3000.00	0.00	0.00	0.00	0.00	0.00	60000.00	\N
71	5	33	\N	20	pcs	400.00	0.00	0.00	0.00	0.00	0.00	8000.00	\N
72	5	34	\N	20	pcs	300.00	0.00	0.00	0.00	0.00	0.00	6000.00	\N
73	5	35	\N	20	pcs	7000.00	0.00	0.00	0.00	0.00	0.00	140000.00	\N
74	5	36	\N	20	pcs	1200.00	0.00	0.00	0.00	0.00	0.00	24000.00	\N
75	5	37	\N	20	pcs	2000.00	0.00	0.00	0.00	0.00	0.00	40000.00	\N
\.


--
-- Data for Name: purchase_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_entries (id, entry_number, invoice_number, invoice_date, vendor_id, vendor_address, vendor_gstin, tax_inclusive, taxable_amount, total_gst_amount, total_invoice_value, status, location_id, created_by, created_at, updated_at, notes) FROM stdin;
\.


--
-- Data for Name: purchase_entry_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_entry_items (id, purchase_entry_id, item_id, hsn_code, uom, gst_rate, quantity, rate, base_amount, gst_amount, total_amount, stock_updated, stock_level_id) FROM stdin;
\.


--
-- Data for Name: purchase_masters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_masters (id, purchase_number, vendor_id, purchase_date, expected_delivery_date, invoice_number, invoice_date, gst_number, payment_terms, payment_status, sub_total, cgst, sgst, igst, discount, total_amount, notes, status, created_by, created_at, updated_at, payment_method, destination_location_id) FROM stdin;
3	PO-20260107-0001	1	2026-01-07	\N	998898hhbbh	\N	\N	\N	paid	45960.00	0.00	0.00	0.00	0.00	45960.00	\N	received	1	2026-01-07 12:13:26.397519	2026-01-07 12:13:26.511905	\N	1
4	PO-20260107-0002	1	2026-01-07	\N	\N	\N	\N	\N	paid	37070.00	0.00	0.00	0.00	0.00	37070.00	\N	received	1	2026-01-07 12:18:19.536279	2026-01-07 12:18:19.607695	\N	1
5	PO-20260107-0003	1	2026-01-07	\N	\N	\N	\N	\N	paid	338620.00	0.00	0.00	0.00	0.00	338620.00	\N	received	1	2026-01-07 12:21:26.857877	2026-01-07 12:21:26.914848	\N	1
\.


--
-- Data for Name: purchase_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_orders (id, po_number, indent_id, vendor_name, vendor_email, vendor_phone, status, total_amount, created_by, approved_by, created_at, sent_at, expected_delivery_date, notes) FROM stdin;
\.


--
-- Data for Name: recipe_ingredients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipe_ingredients (id, recipe_id, item_id, quantity, uom, notes, inventory_item_id, unit, created_at) FROM stdin;
\.


--
-- Data for Name: recipes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipes (id, name, description, food_item_id, servings, is_active, created_at, updated_at, prep_time_minutes, cook_time_minutes) FROM stdin;
\.


--
-- Data for Name: resort_info; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.resort_info (id, name, address, facebook, instagram, twitter, linkedin, is_active) FROM stdin;
\.


--
-- Data for Name: restock_alerts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.restock_alerts (id, item_id, location_id, current_stock, min_stock, alert_type, status, created_at, acknowledged_at, acknowledged_by, resolved_at, resolved_by, notes) FROM stdin;
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reviews (id, name, comment, rating, is_active) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name, permissions) FROM stdin;
2	guest	["view"]
1	admin	["/dashboard", "/bookings", "/rooms", "/services", "/expenses", "/food-orders", "/food-categories", "/food-items", "/billing", "/packages", "/users", "/roles", "/employees", "/reports", "/account", "/userfrontend_data", "/guestprofiles", "/employee-management"]
3	test_role_1767705403_69	["/dashboard"]
4	manager	["/services","/food-orders","/employee-management","/roles","/expenses","/food-categories","/dashboard","/account","/account/reports","/account/chart-of-accounts"]
\.


--
-- Data for Name: room_assets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.room_assets (id, room_id, item_id, asset_id, qr_code, serial_number, status, purchase_date, purchase_price, last_inspection_date, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: room_consumable_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.room_consumable_assignments (id, room_id, booking_id, assigned_at, assigned_by, notes) FROM stdin;
\.


--
-- Data for Name: room_consumable_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.room_consumable_items (id, assignment_id, item_id, quantity_assigned, uom) FROM stdin;
\.


--
-- Data for Name: room_inventory_audits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.room_inventory_audits (id, room_id, room_inventory_item_id, expected_quantity, found_quantity, consumed_quantity, billed_amount, audit_date, audited_by, notes) FROM stdin;
\.


--
-- Data for Name: room_inventory_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.room_inventory_items (id, room_id, item_id, par_stock, current_stock, last_audit_date, last_audited_by, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rooms (id, number, type, price, status, image_url, adults, children, air_conditioning, wifi, bathroom, living_area, terrace, parking, kitchen, family_room, bbq, garden, dining, breakfast, inventory_location_id) FROM stdin;
3	103	Standard Room	3000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	7
4	104	Standard Room	3000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	8
5	105	Standard Room	3000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	9
6	201	Deluxe Room	5000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	10
7	202	Deluxe Room	5000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	11
8	203	Deluxe Room	5000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	12
9	204	Deluxe Room	5000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	13
10	205	Deluxe Room	5000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	14
11	301	Suite	8000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	15
12	302	Suite	8000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	16
13	303	Suite	8000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	17
14	304	Suite	8000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	18
15	305	Suite	8000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	19
16	401	Executive Suite	12000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	20
17	402	Executive Suite	12000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	21
18	403	Executive Suite	12000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	22
19	404	Executive Suite	12000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	23
20	405	Executive Suite	12000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	24
21	501	Presidential Suite	25000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	25
22	502	Presidential Suite	25000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	26
23	503	Presidential Suite	25000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	27
24	504	Presidential Suite	25000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	28
25	505	Presidential Suite	25000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	29
2	102	Standard Room	3000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	6
1	101	Standard Room	3000	Available	\N	2	0	t	t	t	f	f	f	f	f	f	f	f	f	5
\.


--
-- Data for Name: security_equipment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.security_equipment (id, equipment_type, item_id, asset_id, qr_code, location_id, manufacturer, model, serial_number, ip_address, installation_date, warranty_expiry, amc_expiry, status, assigned_to, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: security_maintenance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.security_maintenance (id, equipment_id, maintenance_type, scheduled_date, completed_date, service_provider, cost, performed_by, description, next_service_due, notes, created_at) FROM stdin;
\.


--
-- Data for Name: security_uniforms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.security_uniforms (id, item_id, employee_id, size, quantity, issued_date, return_date, condition, replacement_required, notes, created_at) FROM stdin;
\.


--
-- Data for Name: service_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_images (id, service_id, image_url) FROM stdin;
\.


--
-- Data for Name: service_inventory_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_inventory_items (service_id, inventory_item_id, quantity, created_at) FROM stdin;
\.


--
-- Data for Name: service_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_requests (id, food_order_id, room_id, employee_id, request_type, description, status, created_at, completed_at, refill_data) FROM stdin;
5	\N	1	\N	cleaning	Room cleaning required after checkout - Room 101 (Guest: alphi)	pending	2026-01-07 12:51:07.075828	\N	\N
6	\N	1	\N	refill	Room inventory refill required after checkout - Room 101 | Previous Guest: alphi | Refill Requirements: | - Mineral Water (1L): 2.0 bottle | - Soda Cans: 1.0 can	pending	2026-01-07 12:51:07.24515	\N	[{"item_id": 8, "item_name": "Mineral Water (1L)", "item_code": "ITM-4601", "quantity_to_refill": 2.0, "unit": "bottle"}, {"item_id": 9, "item_name": "Soda Cans", "item_code": "ITM-8595", "quantity_to_refill": 1.0, "unit": "can"}]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.services (id, name, description, charges, created_at, is_visible_to_guest, average_completion_time, gst_rate) FROM stdin;
\.


--
-- Data for Name: signature_experiences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.signature_experiences (id, title, description, image_url, is_active) FROM stdin;
\.


--
-- Data for Name: stock_issue_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_issue_details (id, issue_id, item_id, issued_quantity, unit, unit_price, notes, batch_lot_number, cost, is_payable, is_paid, rental_price, is_damaged, damage_notes) FROM stdin;
271	47	8	2	bottle	40		\N	80	f	f	\N	f	\N
272	47	9	2	can	60		\N	120	t	f	\N	f	\N
273	48	24	1	pcs	60	Rental price: ₹30	\N	60	t	f	30	f	\N
274	49	21	1	pcs	50	Rental price: ₹50	\N	50	t	f	50	f	\N
275	50	9	1	can	\N	Unused Return	\N	\N	f	f	\N	f	\N
276	50	21	1	pcs	\N	Unused Return	\N	\N	f	f	\N	f	\N
\.


--
-- Data for Name: stock_issues; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_issues (id, issue_number, requisition_id, issued_by, issue_date, notes, created_at, source_location_id, destination_location_id) FROM stdin;
47	ISS-20260107-001	\N	1	2026-01-07 18:11:20	Extra allocation for booking BK-000004 (2 payable, 2 comp) - Source: 1	2026-01-07 12:41:13.543474	1	5
48	ISS-20260107-002	\N	1	2026-01-07 18:15:01.733	Rentable asset: 3-Pin Plug	2026-01-07 12:44:54.459216	1	5
49	ISS-20260107-003	\N	1	2026-01-07 18:15:02.027	Rentable asset: LED Bulb 9W	2026-01-07 12:44:54.741847	1	5
50	ISS-20260107-004	\N	1	2026-01-07 12:49:49.76807	Auto-return from Checkout Room 101	2026-01-07 12:49:49.770412	5	1
\.


--
-- Data for Name: stock_levels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_levels (id, item_id, location_id, quantity, uom, expiry_date, batch_number, last_updated) FROM stdin;
\.


--
-- Data for Name: stock_movements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_movements (id, item_id, movement_type, from_location_id, to_location_id, quantity, uom, batch_number, expiry_date, movement_date, moved_by, reference_number, notes, created_at) FROM stdin;
\.


--
-- Data for Name: stock_requisition_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_requisition_details (id, requisition_id, item_id, requested_quantity, unit, notes, approved_quantity) FROM stdin;
\.


--
-- Data for Name: stock_requisitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_requisitions (id, requisition_number, destination_department, requested_by, status, notes, approved_by, approved_at, created_at, updated_at, date_needed, priority) FROM stdin;
\.


--
-- Data for Name: stock_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_usage (id, item_id, location_id, quantity, uom, usage_type, recipe_id, food_order_id, usage_date, used_by, notes) FROM stdin;
\.


--
-- Data for Name: system_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.system_settings (id, key, value, description, updated_at) FROM stdin;
\.


--
-- Data for Name: units_of_measurement; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.units_of_measurement (id, name, symbol, description, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: uom_conversions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.uom_conversions (id, item_id, from_uom, to_uom, conversion_factor) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, email, hashed_password, phone, is_active, role_id) FROM stdin;
2	Basil Abraham	ad@orchid.com	$2b$12$wrJxASSDJvCGj/kL11T6Au.0fWHBKTPp56LE3SrEALTwKBnxrhvgy	09605620416	t	4
1	harry	admin@orchid.com	$2b$12$TxbKp6O90fSRrhDRSGGIC.p9ly.uZEETxPwX7OB3yfXzcANRmRPde	\N	t	1
3	bas	asdf@f.com	$2b$12$DyqSTYwDuVIvKUPGJrpsYOFxS6YAaahwPj0QRzVyWgOCqH8JsxVNq	12345678	t	2
4	alphi	goohgdw@gmail.com	$2b$12$Gyu6hXisPkeLoADMcjW2du9FnYxEOC/hLIJGmHHaQL1ZJi.622MR2	684555855	t	2
\.


--
-- Data for Name: vendor_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vendor_items (id, vendor_id, item_id, unit_price, uom, effective_from, effective_to, is_current, notes, created_at) FROM stdin;
\.


--
-- Data for Name: vendor_performance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vendor_performance (id, vendor_id, period_start, period_end, on_time_delivery_rate, quality_score, price_competitiveness, total_orders, total_value, notes, created_at) FROM stdin;
\.


--
-- Data for Name: vendors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vendors (id, name, code, contact_person, email, phone, address, city, state, country, pincode, gst_number, pan_number, payment_terms, vendor_type, is_active, rating, notes, created_at, updated_at, account_number, ifsc_code, bank_name, upi_id, transaction_id, company_name, gst_registration_type, legal_name, trade_name, qmp_scheme, msme_udyam_no, billing_address, billing_state, shipping_address, distance_km, is_msme_registered, tds_apply, rcm_applicable, preferred_payment_method, account_holder_name, branch_name, upi_mobile_number) FROM stdin;
1	General Supplier	\N	John Doe	supplier@example.com	9876543210	123 Industrial Area	\N	\N	India	\N	29ABCDE1234F1Z5	\N	\N	\N	t	\N	\N	2026-01-06 06:35:12.061881	2026-01-06 06:35:12.061891	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	f	f	f	\N	\N	\N	\N
\.


--
-- Data for Name: vouchers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vouchers (id, code, discount_percent, expiry_date) FROM stdin;
\.


--
-- Data for Name: wastage_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wastage_logs (id, item_id, location_id, quantity, uom, reason, wastage_date, logged_by, notes) FROM stdin;
\.


--
-- Data for Name: waste_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.waste_logs (id, item_id, batch_number, expiry_date, quantity, unit, reason_code, photo_path, notes, reported_by, created_at, log_number, location_id, action_taken, waste_date, food_item_id, is_food_item) FROM stdin;
1	24	\N	\N	1	pcs	Damaged/Missing	\N	Checkout Room 101 (Ref: 3)	1	2026-01-07 12:49:49.805524	WASTE-20260107-001	5	Charged to Guest	2026-01-07 12:49:49.795342	\N	f
2	22	\N	\N	1	pcs	Damaged	\N	Damaged asset during checkout - Room 101. 	1	2026-01-07 12:49:49.857067	WASTE-20260107-002	5	Charged to Guest	2026-01-07 12:49:49.843419	\N	f
\.


--
-- Data for Name: work_order_part_issues; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.work_order_part_issues (id, work_order_id, item_id, quantity, uom, from_location_id, issued_by, issued_date, notes) FROM stdin;
\.


--
-- Data for Name: work_order_parts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.work_order_parts (id, work_order_id, item_id, quantity_required, quantity_issued, uom, notes) FROM stdin;
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.work_orders (id, wo_number, asset_id, location_id, title, description, work_type, priority, status, reported_by, assigned_to, scheduled_date, started_date, completed_date, estimated_cost, actual_cost, service_provider, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: working_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.working_logs (id, employee_id, date, check_in_time, check_out_time, location) FROM stdin;
\.


--
-- Name: account_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.account_groups_id_seq', 1, false);


--
-- Name: account_ledgers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.account_ledgers_id_seq', 1, false);


--
-- Name: approval_matrices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.approval_matrices_id_seq', 1, false);


--
-- Name: approval_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.approval_requests_id_seq', 1, false);


--
-- Name: asset_inspections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asset_inspections_id_seq', 1, false);


--
-- Name: asset_maintenance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asset_maintenance_id_seq', 1, false);


--
-- Name: asset_mappings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asset_mappings_id_seq', 7, true);


--
-- Name: asset_registry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asset_registry_id_seq', 140, true);


--
-- Name: assigned_services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.assigned_services_id_seq', 1, false);


--
-- Name: attendances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attendances_id_seq', 1, false);


--
-- Name: audit_discrepancies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_discrepancies_id_seq', 1, false);


--
-- Name: booking_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.booking_rooms_id_seq', 4, true);


--
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bookings_id_seq', 4, true);


--
-- Name: check_availability_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.check_availability_id_seq', 1, false);


--
-- Name: checklist_executions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checklist_executions_id_seq', 1, false);


--
-- Name: checklist_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checklist_items_id_seq', 1, false);


--
-- Name: checklist_responses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checklist_responses_id_seq', 1, false);


--
-- Name: checklists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checklists_id_seq', 1, false);


--
-- Name: checkout_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checkout_payments_id_seq', 3, true);


--
-- Name: checkout_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checkout_requests_id_seq', 3, true);


--
-- Name: checkout_verifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checkout_verifications_id_seq', 2, true);


--
-- Name: checkouts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.checkouts_id_seq', 3, true);


--
-- Name: consumable_usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.consumable_usage_id_seq', 1, false);


--
-- Name: cost_centers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cost_centers_id_seq', 1, false);


--
-- Name: damage_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.damage_reports_id_seq', 1, false);


--
-- Name: employee_inventory_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employee_inventory_assignments_id_seq', 1, false);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employees_id_seq', 1, true);


--
-- Name: eod_audit_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.eod_audit_items_id_seq', 1, false);


--
-- Name: eod_audits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.eod_audits_id_seq', 1, false);


--
-- Name: expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.expenses_id_seq', 1, false);


--
-- Name: expiry_alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.expiry_alerts_id_seq', 1, false);


--
-- Name: fire_safety_equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fire_safety_equipment_id_seq', 1, false);


--
-- Name: fire_safety_incidents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fire_safety_incidents_id_seq', 1, false);


--
-- Name: fire_safety_inspections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fire_safety_inspections_id_seq', 1, false);


--
-- Name: fire_safety_maintenance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fire_safety_maintenance_id_seq', 1, false);


--
-- Name: first_aid_kit_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.first_aid_kit_items_id_seq', 1, false);


--
-- Name: first_aid_kits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.first_aid_kits_id_seq', 1, false);


--
-- Name: food_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.food_categories_id_seq', 1, false);


--
-- Name: food_item_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.food_item_images_id_seq', 1, false);


--
-- Name: food_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.food_items_id_seq', 1, false);


--
-- Name: food_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.food_order_items_id_seq', 1, false);


--
-- Name: food_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.food_orders_id_seq', 1, false);


--
-- Name: gallery_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.gallery_id_seq', 1, false);


--
-- Name: goods_received_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.goods_received_notes_id_seq', 1, false);


--
-- Name: grn_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.grn_items_id_seq', 1, false);


--
-- Name: guest_suggestions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.guest_suggestions_id_seq', 1, false);


--
-- Name: header_banner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.header_banner_id_seq', 1, false);


--
-- Name: indent_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.indent_items_id_seq', 1, false);


--
-- Name: indents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.indents_id_seq', 1, false);


--
-- Name: inventory_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_categories_id_seq', 10, true);


--
-- Name: inventory_expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_expenses_id_seq', 1, false);


--
-- Name: inventory_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_items_id_seq', 37, true);


--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_transactions_id_seq', 669, true);


--
-- Name: journal_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.journal_entries_id_seq', 1, false);


--
-- Name: journal_entry_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.journal_entry_lines_id_seq', 1, false);


--
-- Name: key_management_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.key_management_id_seq', 1, false);


--
-- Name: key_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.key_movements_id_seq', 1, false);


--
-- Name: laundry_services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.laundry_services_id_seq', 1, false);


--
-- Name: leaves_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.leaves_id_seq', 1, false);


--
-- Name: legal_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.legal_documents_id_seq', 1, false);


--
-- Name: linen_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.linen_items_id_seq', 1, false);


--
-- Name: linen_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.linen_movements_id_seq', 1, false);


--
-- Name: linen_stocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.linen_stocks_id_seq', 1, false);


--
-- Name: linen_wash_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.linen_wash_logs_id_seq', 1, false);


--
-- Name: location_stocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.location_stocks_id_seq', 375, true);


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.locations_id_seq', 29, true);


--
-- Name: lost_found_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lost_found_id_seq', 1, false);


--
-- Name: maintenance_tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.maintenance_tickets_id_seq', 1, false);


--
-- Name: nearby_attraction_banners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.nearby_attraction_banners_id_seq', 1, false);


--
-- Name: nearby_attractions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.nearby_attractions_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: office_inventory_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.office_inventory_items_id_seq', 1, false);


--
-- Name: office_requisitions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.office_requisitions_id_seq', 1, false);


--
-- Name: outlet_stocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.outlet_stocks_id_seq', 1, false);


--
-- Name: outlets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.outlets_id_seq', 1, false);


--
-- Name: package_booking_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.package_booking_rooms_id_seq', 1, false);


--
-- Name: package_bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.package_bookings_id_seq', 1, false);


--
-- Name: package_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.package_images_id_seq', 1, false);


--
-- Name: packages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.packages_id_seq', 1, false);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_id_seq', 1, false);


--
-- Name: perishable_batches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.perishable_batches_id_seq', 1, false);


--
-- Name: plan_weddings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plan_weddings_id_seq', 1, false);


--
-- Name: po_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.po_items_id_seq', 1, false);


--
-- Name: purchase_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_details_id_seq', 75, true);


--
-- Name: purchase_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_entries_id_seq', 1, false);


--
-- Name: purchase_entry_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_entry_items_id_seq', 1, false);


--
-- Name: purchase_masters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_masters_id_seq', 5, true);


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_orders_id_seq', 1, false);


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recipe_ingredients_id_seq', 1, false);


--
-- Name: recipes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recipes_id_seq', 1, false);


--
-- Name: resort_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.resort_info_id_seq', 1, false);


--
-- Name: restock_alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.restock_alerts_id_seq', 1, false);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reviews_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: room_assets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.room_assets_id_seq', 1, false);


--
-- Name: room_consumable_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.room_consumable_assignments_id_seq', 1, false);


--
-- Name: room_consumable_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.room_consumable_items_id_seq', 1, false);


--
-- Name: room_inventory_audits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.room_inventory_audits_id_seq', 1, false);


--
-- Name: room_inventory_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.room_inventory_items_id_seq', 1, false);


--
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rooms_id_seq', 25, true);


--
-- Name: security_equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.security_equipment_id_seq', 1, false);


--
-- Name: security_maintenance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.security_maintenance_id_seq', 1, false);


--
-- Name: security_uniforms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.security_uniforms_id_seq', 1, false);


--
-- Name: service_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.service_images_id_seq', 1, false);


--
-- Name: service_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.service_requests_id_seq', 6, true);


--
-- Name: services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.services_id_seq', 1, false);


--
-- Name: signature_experiences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.signature_experiences_id_seq', 1, false);


--
-- Name: stock_issue_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_issue_details_id_seq', 276, true);


--
-- Name: stock_issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_issues_id_seq', 50, true);


--
-- Name: stock_levels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_levels_id_seq', 1, false);


--
-- Name: stock_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_movements_id_seq', 1, false);


--
-- Name: stock_requisition_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_requisition_details_id_seq', 1, false);


--
-- Name: stock_requisitions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_requisitions_id_seq', 1, false);


--
-- Name: stock_usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_usage_id_seq', 1, false);


--
-- Name: system_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.system_settings_id_seq', 1, false);


--
-- Name: units_of_measurement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.units_of_measurement_id_seq', 1, false);


--
-- Name: uom_conversions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.uom_conversions_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: vendor_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vendor_items_id_seq', 1, false);


--
-- Name: vendor_performance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vendor_performance_id_seq', 1, false);


--
-- Name: vendors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vendors_id_seq', 1, true);


--
-- Name: vouchers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vouchers_id_seq', 1, false);


--
-- Name: wastage_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wastage_logs_id_seq', 1, false);


--
-- Name: waste_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.waste_logs_id_seq', 2, true);


--
-- Name: work_order_part_issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.work_order_part_issues_id_seq', 1, false);


--
-- Name: work_order_parts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.work_order_parts_id_seq', 1, false);


--
-- Name: work_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.work_orders_id_seq', 1, false);


--
-- Name: working_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.working_logs_id_seq', 1, false);


--
-- Name: account_groups account_groups_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_groups
    ADD CONSTRAINT account_groups_name_key UNIQUE (name);


--
-- Name: account_groups account_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_groups
    ADD CONSTRAINT account_groups_pkey PRIMARY KEY (id);


--
-- Name: account_ledgers account_ledgers_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_ledgers
    ADD CONSTRAINT account_ledgers_code_key UNIQUE (code);


--
-- Name: account_ledgers account_ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_ledgers
    ADD CONSTRAINT account_ledgers_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: approval_matrices approval_matrices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approval_matrices
    ADD CONSTRAINT approval_matrices_pkey PRIMARY KEY (id);


--
-- Name: approval_requests approval_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approval_requests
    ADD CONSTRAINT approval_requests_pkey PRIMARY KEY (id);


--
-- Name: asset_inspections asset_inspections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_inspections
    ADD CONSTRAINT asset_inspections_pkey PRIMARY KEY (id);


--
-- Name: asset_maintenance asset_maintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_maintenance
    ADD CONSTRAINT asset_maintenance_pkey PRIMARY KEY (id);


--
-- Name: asset_mappings asset_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_mappings
    ADD CONSTRAINT asset_mappings_pkey PRIMARY KEY (id);


--
-- Name: asset_registry asset_registry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_registry
    ADD CONSTRAINT asset_registry_pkey PRIMARY KEY (id);


--
-- Name: assigned_services assigned_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assigned_services
    ADD CONSTRAINT assigned_services_pkey PRIMARY KEY (id);


--
-- Name: attendances attendances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT attendances_pkey PRIMARY KEY (id);


--
-- Name: audit_discrepancies audit_discrepancies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_discrepancies
    ADD CONSTRAINT audit_discrepancies_pkey PRIMARY KEY (id);


--
-- Name: booking_rooms booking_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_rooms
    ADD CONSTRAINT booking_rooms_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: check_availability check_availability_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_availability
    ADD CONSTRAINT check_availability_pkey PRIMARY KEY (id);


--
-- Name: checklist_executions checklist_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_executions
    ADD CONSTRAINT checklist_executions_pkey PRIMARY KEY (id);


--
-- Name: checklist_items checklist_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT checklist_items_pkey PRIMARY KEY (id);


--
-- Name: checklist_responses checklist_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_responses
    ADD CONSTRAINT checklist_responses_pkey PRIMARY KEY (id);


--
-- Name: checklists checklists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklists
    ADD CONSTRAINT checklists_pkey PRIMARY KEY (id);


--
-- Name: checkout_payments checkout_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_payments
    ADD CONSTRAINT checkout_payments_pkey PRIMARY KEY (id);


--
-- Name: checkout_requests checkout_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_requests
    ADD CONSTRAINT checkout_requests_pkey PRIMARY KEY (id);


--
-- Name: checkout_verifications checkout_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_verifications
    ADD CONSTRAINT checkout_verifications_pkey PRIMARY KEY (id);


--
-- Name: checkouts checkouts_booking_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts
    ADD CONSTRAINT checkouts_booking_id_key UNIQUE (booking_id);


--
-- Name: checkouts checkouts_package_booking_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts
    ADD CONSTRAINT checkouts_package_booking_id_key UNIQUE (package_booking_id);


--
-- Name: checkouts checkouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts
    ADD CONSTRAINT checkouts_pkey PRIMARY KEY (id);


--
-- Name: consumable_usage consumable_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumable_usage
    ADD CONSTRAINT consumable_usage_pkey PRIMARY KEY (id);


--
-- Name: cost_centers cost_centers_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_centers
    ADD CONSTRAINT cost_centers_code_key UNIQUE (code);


--
-- Name: cost_centers cost_centers_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_centers
    ADD CONSTRAINT cost_centers_name_key UNIQUE (name);


--
-- Name: cost_centers cost_centers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_centers
    ADD CONSTRAINT cost_centers_pkey PRIMARY KEY (id);


--
-- Name: damage_reports damage_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_reports
    ADD CONSTRAINT damage_reports_pkey PRIMARY KEY (id);


--
-- Name: employee_inventory_assignments employee_inventory_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_inventory_assignments
    ADD CONSTRAINT employee_inventory_assignments_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: employees employees_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_key UNIQUE (user_id);


--
-- Name: eod_audit_items eod_audit_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eod_audit_items
    ADD CONSTRAINT eod_audit_items_pkey PRIMARY KEY (id);


--
-- Name: eod_audits eod_audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eod_audits
    ADD CONSTRAINT eod_audits_pkey PRIMARY KEY (id);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


--
-- Name: expiry_alerts expiry_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expiry_alerts
    ADD CONSTRAINT expiry_alerts_pkey PRIMARY KEY (id);


--
-- Name: fire_safety_equipment fire_safety_equipment_asset_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_equipment
    ADD CONSTRAINT fire_safety_equipment_asset_id_key UNIQUE (asset_id);


--
-- Name: fire_safety_equipment fire_safety_equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_equipment
    ADD CONSTRAINT fire_safety_equipment_pkey PRIMARY KEY (id);


--
-- Name: fire_safety_incidents fire_safety_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_incidents
    ADD CONSTRAINT fire_safety_incidents_pkey PRIMARY KEY (id);


--
-- Name: fire_safety_inspections fire_safety_inspections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_inspections
    ADD CONSTRAINT fire_safety_inspections_pkey PRIMARY KEY (id);


--
-- Name: fire_safety_maintenance fire_safety_maintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_maintenance
    ADD CONSTRAINT fire_safety_maintenance_pkey PRIMARY KEY (id);


--
-- Name: first_aid_kit_items first_aid_kit_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_aid_kit_items
    ADD CONSTRAINT first_aid_kit_items_pkey PRIMARY KEY (id);


--
-- Name: first_aid_kits first_aid_kits_kit_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_aid_kits
    ADD CONSTRAINT first_aid_kits_kit_number_key UNIQUE (kit_number);


--
-- Name: first_aid_kits first_aid_kits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_aid_kits
    ADD CONSTRAINT first_aid_kits_pkey PRIMARY KEY (id);


--
-- Name: food_categories food_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_categories
    ADD CONSTRAINT food_categories_pkey PRIMARY KEY (id);


--
-- Name: food_item_images food_item_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_item_images
    ADD CONSTRAINT food_item_images_pkey PRIMARY KEY (id);


--
-- Name: food_items food_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_items
    ADD CONSTRAINT food_items_pkey PRIMARY KEY (id);


--
-- Name: food_order_items food_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_order_items
    ADD CONSTRAINT food_order_items_pkey PRIMARY KEY (id);


--
-- Name: food_orders food_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_orders
    ADD CONSTRAINT food_orders_pkey PRIMARY KEY (id);


--
-- Name: gallery gallery_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gallery
    ADD CONSTRAINT gallery_pkey PRIMARY KEY (id);


--
-- Name: goods_received_notes goods_received_notes_grn_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_grn_number_key UNIQUE (grn_number);


--
-- Name: goods_received_notes goods_received_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_pkey PRIMARY KEY (id);


--
-- Name: grn_items grn_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_pkey PRIMARY KEY (id);


--
-- Name: guest_suggestions guest_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_suggestions
    ADD CONSTRAINT guest_suggestions_pkey PRIMARY KEY (id);


--
-- Name: header_banner header_banner_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.header_banner
    ADD CONSTRAINT header_banner_pkey PRIMARY KEY (id);


--
-- Name: indent_items indent_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indent_items
    ADD CONSTRAINT indent_items_pkey PRIMARY KEY (id);


--
-- Name: indents indents_indent_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indents
    ADD CONSTRAINT indents_indent_number_key UNIQUE (indent_number);


--
-- Name: indents indents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indents
    ADD CONSTRAINT indents_pkey PRIMARY KEY (id);


--
-- Name: inventory_categories inventory_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_categories
    ADD CONSTRAINT inventory_categories_name_key UNIQUE (name);


--
-- Name: inventory_categories inventory_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_categories
    ADD CONSTRAINT inventory_categories_pkey PRIMARY KEY (id);


--
-- Name: inventory_expenses inventory_expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_expenses
    ADD CONSTRAINT inventory_expenses_pkey PRIMARY KEY (id);


--
-- Name: inventory_items inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_pkey PRIMARY KEY (id);


--
-- Name: inventory_items inventory_items_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_sku_key UNIQUE (sku);


--
-- Name: inventory_transactions inventory_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_pkey PRIMARY KEY (id);


--
-- Name: journal_entries journal_entries_entry_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_entry_number_key UNIQUE (entry_number);


--
-- Name: journal_entries journal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (id);


--
-- Name: journal_entry_lines journal_entry_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entry_lines
    ADD CONSTRAINT journal_entry_lines_pkey PRIMARY KEY (id);


--
-- Name: key_management key_management_key_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_management
    ADD CONSTRAINT key_management_key_number_key UNIQUE (key_number);


--
-- Name: key_management key_management_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_management
    ADD CONSTRAINT key_management_pkey PRIMARY KEY (id);


--
-- Name: key_movements key_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_movements
    ADD CONSTRAINT key_movements_pkey PRIMARY KEY (id);


--
-- Name: laundry_services laundry_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.laundry_services
    ADD CONSTRAINT laundry_services_pkey PRIMARY KEY (id);


--
-- Name: leaves leaves_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaves
    ADD CONSTRAINT leaves_pkey PRIMARY KEY (id);


--
-- Name: legal_documents legal_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_documents
    ADD CONSTRAINT legal_documents_pkey PRIMARY KEY (id);


--
-- Name: linen_items linen_items_barcode_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_items
    ADD CONSTRAINT linen_items_barcode_key UNIQUE (barcode);


--
-- Name: linen_items linen_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_items
    ADD CONSTRAINT linen_items_pkey PRIMARY KEY (id);


--
-- Name: linen_items linen_items_rfid_tag_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_items
    ADD CONSTRAINT linen_items_rfid_tag_key UNIQUE (rfid_tag);


--
-- Name: linen_movements linen_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_movements
    ADD CONSTRAINT linen_movements_pkey PRIMARY KEY (id);


--
-- Name: linen_stocks linen_stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_stocks
    ADD CONSTRAINT linen_stocks_pkey PRIMARY KEY (id);


--
-- Name: linen_wash_logs linen_wash_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_wash_logs
    ADD CONSTRAINT linen_wash_logs_pkey PRIMARY KEY (id);


--
-- Name: location_stocks location_stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_stocks
    ADD CONSTRAINT location_stocks_pkey PRIMARY KEY (id);


--
-- Name: locations locations_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_code_key UNIQUE (code);


--
-- Name: locations locations_location_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_location_code_key UNIQUE (location_code);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: lost_found lost_found_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lost_found
    ADD CONSTRAINT lost_found_pkey PRIMARY KEY (id);


--
-- Name: maintenance_tickets maintenance_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT maintenance_tickets_pkey PRIMARY KEY (id);


--
-- Name: nearby_attraction_banners nearby_attraction_banners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nearby_attraction_banners
    ADD CONSTRAINT nearby_attraction_banners_pkey PRIMARY KEY (id);


--
-- Name: nearby_attractions nearby_attractions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nearby_attractions
    ADD CONSTRAINT nearby_attractions_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: office_inventory_items office_inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_inventory_items
    ADD CONSTRAINT office_inventory_items_pkey PRIMARY KEY (id);


--
-- Name: office_requisitions office_requisitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_requisitions
    ADD CONSTRAINT office_requisitions_pkey PRIMARY KEY (id);


--
-- Name: office_requisitions office_requisitions_req_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_requisitions
    ADD CONSTRAINT office_requisitions_req_number_key UNIQUE (req_number);


--
-- Name: outlet_stocks outlet_stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outlet_stocks
    ADD CONSTRAINT outlet_stocks_pkey PRIMARY KEY (id);


--
-- Name: outlets outlets_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outlets
    ADD CONSTRAINT outlets_code_key UNIQUE (code);


--
-- Name: outlets outlets_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outlets
    ADD CONSTRAINT outlets_name_key UNIQUE (name);


--
-- Name: outlets outlets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outlets
    ADD CONSTRAINT outlets_pkey PRIMARY KEY (id);


--
-- Name: package_booking_rooms package_booking_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_booking_rooms
    ADD CONSTRAINT package_booking_rooms_pkey PRIMARY KEY (id);


--
-- Name: package_bookings package_bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_bookings
    ADD CONSTRAINT package_bookings_pkey PRIMARY KEY (id);


--
-- Name: package_images package_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_images
    ADD CONSTRAINT package_images_pkey PRIMARY KEY (id);


--
-- Name: packages packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT packages_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: perishable_batches perishable_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perishable_batches
    ADD CONSTRAINT perishable_batches_pkey PRIMARY KEY (id);


--
-- Name: plan_weddings plan_weddings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_weddings
    ADD CONSTRAINT plan_weddings_pkey PRIMARY KEY (id);


--
-- Name: po_items po_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.po_items
    ADD CONSTRAINT po_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_details purchase_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_details
    ADD CONSTRAINT purchase_details_pkey PRIMARY KEY (id);


--
-- Name: purchase_entries purchase_entries_entry_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entries
    ADD CONSTRAINT purchase_entries_entry_number_key UNIQUE (entry_number);


--
-- Name: purchase_entries purchase_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entries
    ADD CONSTRAINT purchase_entries_pkey PRIMARY KEY (id);


--
-- Name: purchase_entry_items purchase_entry_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entry_items
    ADD CONSTRAINT purchase_entry_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_masters purchase_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_masters
    ADD CONSTRAINT purchase_masters_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_po_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_po_number_key UNIQUE (po_number);


--
-- Name: recipe_ingredients recipe_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_pkey PRIMARY KEY (id);


--
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- Name: resort_info resort_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resort_info
    ADD CONSTRAINT resort_info_pkey PRIMARY KEY (id);


--
-- Name: restock_alerts restock_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restock_alerts
    ADD CONSTRAINT restock_alerts_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: room_assets room_assets_asset_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_assets
    ADD CONSTRAINT room_assets_asset_id_key UNIQUE (asset_id);


--
-- Name: room_assets room_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_assets
    ADD CONSTRAINT room_assets_pkey PRIMARY KEY (id);


--
-- Name: room_consumable_assignments room_consumable_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_consumable_assignments
    ADD CONSTRAINT room_consumable_assignments_pkey PRIMARY KEY (id);


--
-- Name: room_consumable_items room_consumable_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_consumable_items
    ADD CONSTRAINT room_consumable_items_pkey PRIMARY KEY (id);


--
-- Name: room_inventory_audits room_inventory_audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_audits
    ADD CONSTRAINT room_inventory_audits_pkey PRIMARY KEY (id);


--
-- Name: room_inventory_items room_inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_items
    ADD CONSTRAINT room_inventory_items_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_number_key UNIQUE (number);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: security_equipment security_equipment_asset_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_equipment
    ADD CONSTRAINT security_equipment_asset_id_key UNIQUE (asset_id);


--
-- Name: security_equipment security_equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_equipment
    ADD CONSTRAINT security_equipment_pkey PRIMARY KEY (id);


--
-- Name: security_maintenance security_maintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_maintenance
    ADD CONSTRAINT security_maintenance_pkey PRIMARY KEY (id);


--
-- Name: security_uniforms security_uniforms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_uniforms
    ADD CONSTRAINT security_uniforms_pkey PRIMARY KEY (id);


--
-- Name: service_images service_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_images
    ADD CONSTRAINT service_images_pkey PRIMARY KEY (id);


--
-- Name: service_inventory_items service_inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_inventory_items
    ADD CONSTRAINT service_inventory_items_pkey PRIMARY KEY (service_id, inventory_item_id);


--
-- Name: service_requests service_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_requests
    ADD CONSTRAINT service_requests_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: signature_experiences signature_experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signature_experiences
    ADD CONSTRAINT signature_experiences_pkey PRIMARY KEY (id);


--
-- Name: stock_issue_details stock_issue_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issue_details
    ADD CONSTRAINT stock_issue_details_pkey PRIMARY KEY (id);


--
-- Name: stock_issues stock_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issues
    ADD CONSTRAINT stock_issues_pkey PRIMARY KEY (id);


--
-- Name: stock_levels stock_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_levels
    ADD CONSTRAINT stock_levels_pkey PRIMARY KEY (id);


--
-- Name: stock_movements stock_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_pkey PRIMARY KEY (id);


--
-- Name: stock_requisition_details stock_requisition_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_requisition_details
    ADD CONSTRAINT stock_requisition_details_pkey PRIMARY KEY (id);


--
-- Name: stock_requisitions stock_requisitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_requisitions
    ADD CONSTRAINT stock_requisitions_pkey PRIMARY KEY (id);


--
-- Name: stock_usage stock_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_usage
    ADD CONSTRAINT stock_usage_pkey PRIMARY KEY (id);


--
-- Name: system_settings system_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (id);


--
-- Name: units_of_measurement units_of_measurement_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_of_measurement
    ADD CONSTRAINT units_of_measurement_name_key UNIQUE (name);


--
-- Name: units_of_measurement units_of_measurement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_of_measurement
    ADD CONSTRAINT units_of_measurement_pkey PRIMARY KEY (id);


--
-- Name: uom_conversions uom_conversions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uom_conversions
    ADD CONSTRAINT uom_conversions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendor_items vendor_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_items
    ADD CONSTRAINT vendor_items_pkey PRIMARY KEY (id);


--
-- Name: vendor_performance vendor_performance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_performance
    ADD CONSTRAINT vendor_performance_pkey PRIMARY KEY (id);


--
-- Name: vendors vendors_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_code_key UNIQUE (code);


--
-- Name: vendors vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- Name: vouchers vouchers_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vouchers
    ADD CONSTRAINT vouchers_code_key UNIQUE (code);


--
-- Name: vouchers vouchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vouchers
    ADD CONSTRAINT vouchers_pkey PRIMARY KEY (id);


--
-- Name: wastage_logs wastage_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wastage_logs
    ADD CONSTRAINT wastage_logs_pkey PRIMARY KEY (id);


--
-- Name: waste_logs waste_logs_log_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waste_logs
    ADD CONSTRAINT waste_logs_log_number_key UNIQUE (log_number);


--
-- Name: waste_logs waste_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waste_logs
    ADD CONSTRAINT waste_logs_pkey PRIMARY KEY (id);


--
-- Name: work_order_part_issues work_order_part_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_part_issues
    ADD CONSTRAINT work_order_part_issues_pkey PRIMARY KEY (id);


--
-- Name: work_order_parts work_order_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_parts
    ADD CONSTRAINT work_order_parts_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_wo_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_wo_number_key UNIQUE (wo_number);


--
-- Name: working_logs working_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.working_logs
    ADD CONSTRAINT working_logs_pkey PRIMARY KEY (id);


--
-- Name: idx_account_ledgers_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_account_ledgers_group_id ON public.account_ledgers USING btree (group_id);


--
-- Name: idx_booking_check_in; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_booking_check_in ON public.bookings USING btree (check_in);


--
-- Name: idx_booking_check_out; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_booking_check_out ON public.bookings USING btree (check_out);


--
-- Name: idx_booking_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_booking_status ON public.bookings USING btree (status);


--
-- Name: idx_checkout_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_checkout_booking_id ON public.checkouts USING btree (booking_id);


--
-- Name: idx_checkout_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_checkout_date ON public.checkouts USING btree (checkout_date);


--
-- Name: idx_checkout_package_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_checkout_package_booking_id ON public.checkouts USING btree (package_booking_id);


--
-- Name: idx_checkout_payments_checkout_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_checkout_payments_checkout_id ON public.checkout_payments USING btree (checkout_id);


--
-- Name: idx_checkout_room_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_checkout_room_number ON public.checkouts USING btree (room_number);


--
-- Name: idx_checkout_verifications_checkout_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_checkout_verifications_checkout_id ON public.checkout_verifications USING btree (checkout_id);


--
-- Name: idx_checkouts_invoice_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_checkouts_invoice_number ON public.checkouts USING btree (invoice_number) WHERE (invoice_number IS NOT NULL);


--
-- Name: idx_expense_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_expense_date ON public.expenses USING btree (date);


--
-- Name: idx_expense_employee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_expense_employee_id ON public.expenses USING btree (employee_id);


--
-- Name: idx_food_order_billing_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_food_order_billing_status ON public.food_orders USING btree (billing_status);


--
-- Name: idx_food_order_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_food_order_room_id ON public.food_orders USING btree (room_id);


--
-- Name: idx_food_order_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_food_order_status ON public.food_orders USING btree (status);


--
-- Name: idx_inventory_item_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_item_category_id ON public.inventory_items USING btree (category_id);


--
-- Name: idx_inventory_items_item_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_items_item_code ON public.inventory_items USING btree (item_code);


--
-- Name: idx_inventory_transaction_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_transaction_item_id ON public.inventory_transactions USING btree (item_id);


--
-- Name: idx_journal_entries_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entries_date ON public.journal_entries USING btree (entry_date);


--
-- Name: idx_journal_entries_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entries_reference ON public.journal_entries USING btree (reference_type, reference_id);


--
-- Name: idx_journal_entry_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entry_date ON public.journal_entries USING btree (entry_date);


--
-- Name: idx_journal_entry_line_credit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entry_line_credit ON public.journal_entry_lines USING btree (credit_ledger_id);


--
-- Name: idx_journal_entry_line_debit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entry_line_debit ON public.journal_entry_lines USING btree (debit_ledger_id);


--
-- Name: idx_journal_entry_lines_credit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entry_lines_credit ON public.journal_entry_lines USING btree (credit_ledger_id);


--
-- Name: idx_journal_entry_lines_debit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entry_lines_debit ON public.journal_entry_lines USING btree (debit_ledger_id);


--
-- Name: idx_journal_entry_lines_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entry_lines_entry_id ON public.journal_entry_lines USING btree (entry_id);


--
-- Name: idx_journal_entry_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entry_reference ON public.journal_entries USING btree (reference_type, reference_id);


--
-- Name: idx_locations_location_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_locations_location_code ON public.locations USING btree (location_code);


--
-- Name: idx_purchase_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_purchase_vendor_id ON public.purchase_masters USING btree (vendor_id);


--
-- Name: idx_recipe_ingredients_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recipe_ingredients_inventory_item_id ON public.recipe_ingredients USING btree (inventory_item_id);


--
-- Name: idx_room_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_room_number ON public.rooms USING btree (number);


--
-- Name: idx_room_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_room_status ON public.rooms USING btree (status);


--
-- Name: idx_waste_logs_log_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_waste_logs_log_number ON public.waste_logs USING btree (log_number);


--
-- Name: ix_account_groups_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_account_groups_id ON public.account_groups USING btree (id);


--
-- Name: ix_account_ledgers_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_account_ledgers_id ON public.account_ledgers USING btree (id);


--
-- Name: ix_approval_matrices_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_approval_matrices_id ON public.approval_matrices USING btree (id);


--
-- Name: ix_approval_requests_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_approval_requests_id ON public.approval_requests USING btree (id);


--
-- Name: ix_asset_inspections_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_inspections_id ON public.asset_inspections USING btree (id);


--
-- Name: ix_asset_maintenance_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_maintenance_id ON public.asset_maintenance USING btree (id);


--
-- Name: ix_asset_mappings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_mappings_id ON public.asset_mappings USING btree (id);


--
-- Name: ix_asset_registry_asset_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_asset_registry_asset_tag_id ON public.asset_registry USING btree (asset_tag_id);


--
-- Name: ix_asset_registry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_registry_id ON public.asset_registry USING btree (id);


--
-- Name: ix_assigned_services_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assigned_services_id ON public.assigned_services USING btree (id);


--
-- Name: ix_attendances_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_attendances_id ON public.attendances USING btree (id);


--
-- Name: ix_audit_discrepancies_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_discrepancies_id ON public.audit_discrepancies USING btree (id);


--
-- Name: ix_booking_rooms_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_booking_rooms_id ON public.booking_rooms USING btree (id);


--
-- Name: ix_bookings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_bookings_id ON public.bookings USING btree (id);


--
-- Name: ix_check_availability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_check_availability_id ON public.check_availability USING btree (id);


--
-- Name: ix_checklist_executions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_checklist_executions_id ON public.checklist_executions USING btree (id);


--
-- Name: ix_checklist_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_checklist_items_id ON public.checklist_items USING btree (id);


--
-- Name: ix_checklist_responses_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_checklist_responses_id ON public.checklist_responses USING btree (id);


--
-- Name: ix_checklists_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_checklists_id ON public.checklists USING btree (id);


--
-- Name: ix_checkout_payments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_checkout_payments_id ON public.checkout_payments USING btree (id);


--
-- Name: ix_checkout_requests_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_checkout_requests_id ON public.checkout_requests USING btree (id);


--
-- Name: ix_checkout_verifications_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_checkout_verifications_id ON public.checkout_verifications USING btree (id);


--
-- Name: ix_checkouts_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_checkouts_id ON public.checkouts USING btree (id);


--
-- Name: ix_consumable_usage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_consumable_usage_id ON public.consumable_usage USING btree (id);


--
-- Name: ix_cost_centers_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cost_centers_id ON public.cost_centers USING btree (id);


--
-- Name: ix_damage_reports_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_damage_reports_id ON public.damage_reports USING btree (id);


--
-- Name: ix_employee_inventory_assignments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_employee_inventory_assignments_id ON public.employee_inventory_assignments USING btree (id);


--
-- Name: ix_employees_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_employees_id ON public.employees USING btree (id);


--
-- Name: ix_eod_audit_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_eod_audit_items_id ON public.eod_audit_items USING btree (id);


--
-- Name: ix_eod_audits_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_eod_audits_id ON public.eod_audits USING btree (id);


--
-- Name: ix_expenses_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_expenses_id ON public.expenses USING btree (id);


--
-- Name: ix_expenses_self_invoice_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_expenses_self_invoice_number ON public.expenses USING btree (self_invoice_number);


--
-- Name: ix_expiry_alerts_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_expiry_alerts_id ON public.expiry_alerts USING btree (id);


--
-- Name: ix_fire_safety_equipment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_fire_safety_equipment_id ON public.fire_safety_equipment USING btree (id);


--
-- Name: ix_fire_safety_incidents_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_fire_safety_incidents_id ON public.fire_safety_incidents USING btree (id);


--
-- Name: ix_fire_safety_inspections_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_fire_safety_inspections_id ON public.fire_safety_inspections USING btree (id);


--
-- Name: ix_fire_safety_maintenance_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_fire_safety_maintenance_id ON public.fire_safety_maintenance USING btree (id);


--
-- Name: ix_first_aid_kit_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_first_aid_kit_items_id ON public.first_aid_kit_items USING btree (id);


--
-- Name: ix_first_aid_kits_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_first_aid_kits_id ON public.first_aid_kits USING btree (id);


--
-- Name: ix_food_categories_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_food_categories_id ON public.food_categories USING btree (id);


--
-- Name: ix_food_item_images_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_food_item_images_id ON public.food_item_images USING btree (id);


--
-- Name: ix_food_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_food_items_id ON public.food_items USING btree (id);


--
-- Name: ix_food_order_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_food_order_items_id ON public.food_order_items USING btree (id);


--
-- Name: ix_food_orders_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_food_orders_id ON public.food_orders USING btree (id);


--
-- Name: ix_gallery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_gallery_id ON public.gallery USING btree (id);


--
-- Name: ix_goods_received_notes_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_goods_received_notes_id ON public.goods_received_notes USING btree (id);


--
-- Name: ix_grn_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_grn_items_id ON public.grn_items USING btree (id);


--
-- Name: ix_guest_suggestions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_guest_suggestions_id ON public.guest_suggestions USING btree (id);


--
-- Name: ix_header_banner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_header_banner_id ON public.header_banner USING btree (id);


--
-- Name: ix_indent_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_indent_items_id ON public.indent_items USING btree (id);


--
-- Name: ix_indents_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_indents_id ON public.indents USING btree (id);


--
-- Name: ix_inventory_categories_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_inventory_categories_id ON public.inventory_categories USING btree (id);


--
-- Name: ix_inventory_expenses_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_inventory_expenses_id ON public.inventory_expenses USING btree (id);


--
-- Name: ix_inventory_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_inventory_items_id ON public.inventory_items USING btree (id);


--
-- Name: ix_inventory_transactions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_inventory_transactions_id ON public.inventory_transactions USING btree (id);


--
-- Name: ix_journal_entries_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_journal_entries_id ON public.journal_entries USING btree (id);


--
-- Name: ix_journal_entry_lines_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_journal_entry_lines_id ON public.journal_entry_lines USING btree (id);


--
-- Name: ix_key_management_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_key_management_id ON public.key_management USING btree (id);


--
-- Name: ix_key_movements_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_key_movements_id ON public.key_movements USING btree (id);


--
-- Name: ix_laundry_services_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_laundry_services_id ON public.laundry_services USING btree (id);


--
-- Name: ix_leaves_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_leaves_id ON public.leaves USING btree (id);


--
-- Name: ix_legal_documents_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_legal_documents_id ON public.legal_documents USING btree (id);


--
-- Name: ix_linen_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_linen_items_id ON public.linen_items USING btree (id);


--
-- Name: ix_linen_movements_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_linen_movements_id ON public.linen_movements USING btree (id);


--
-- Name: ix_linen_stocks_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_linen_stocks_id ON public.linen_stocks USING btree (id);


--
-- Name: ix_linen_wash_logs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_linen_wash_logs_id ON public.linen_wash_logs USING btree (id);


--
-- Name: ix_location_stocks_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_location_stocks_id ON public.location_stocks USING btree (id);


--
-- Name: ix_locations_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_locations_id ON public.locations USING btree (id);


--
-- Name: ix_lost_found_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_lost_found_id ON public.lost_found USING btree (id);


--
-- Name: ix_maintenance_tickets_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_maintenance_tickets_id ON public.maintenance_tickets USING btree (id);


--
-- Name: ix_nearby_attraction_banners_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_nearby_attraction_banners_id ON public.nearby_attraction_banners USING btree (id);


--
-- Name: ix_nearby_attractions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_nearby_attractions_id ON public.nearby_attractions USING btree (id);


--
-- Name: ix_notifications_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notifications_id ON public.notifications USING btree (id);


--
-- Name: ix_office_inventory_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_office_inventory_items_id ON public.office_inventory_items USING btree (id);


--
-- Name: ix_office_requisitions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_office_requisitions_id ON public.office_requisitions USING btree (id);


--
-- Name: ix_outlet_stocks_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_outlet_stocks_id ON public.outlet_stocks USING btree (id);


--
-- Name: ix_outlets_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_outlets_id ON public.outlets USING btree (id);


--
-- Name: ix_package_booking_rooms_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_package_booking_rooms_id ON public.package_booking_rooms USING btree (id);


--
-- Name: ix_package_bookings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_package_bookings_id ON public.package_bookings USING btree (id);


--
-- Name: ix_package_images_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_package_images_id ON public.package_images USING btree (id);


--
-- Name: ix_packages_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_packages_id ON public.packages USING btree (id);


--
-- Name: ix_payments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_payments_id ON public.payments USING btree (id);


--
-- Name: ix_perishable_batches_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_perishable_batches_id ON public.perishable_batches USING btree (id);


--
-- Name: ix_plan_weddings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_plan_weddings_id ON public.plan_weddings USING btree (id);


--
-- Name: ix_po_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_po_items_id ON public.po_items USING btree (id);


--
-- Name: ix_purchase_details_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_purchase_details_id ON public.purchase_details USING btree (id);


--
-- Name: ix_purchase_entries_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_purchase_entries_id ON public.purchase_entries USING btree (id);


--
-- Name: ix_purchase_entry_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_purchase_entry_items_id ON public.purchase_entry_items USING btree (id);


--
-- Name: ix_purchase_masters_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_purchase_masters_id ON public.purchase_masters USING btree (id);


--
-- Name: ix_purchase_masters_invoice_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_purchase_masters_invoice_number ON public.purchase_masters USING btree (invoice_number);


--
-- Name: ix_purchase_masters_purchase_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_purchase_masters_purchase_number ON public.purchase_masters USING btree (purchase_number);


--
-- Name: ix_purchase_orders_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_purchase_orders_id ON public.purchase_orders USING btree (id);


--
-- Name: ix_recipe_ingredients_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recipe_ingredients_id ON public.recipe_ingredients USING btree (id);


--
-- Name: ix_recipes_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recipes_id ON public.recipes USING btree (id);


--
-- Name: ix_resort_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_resort_info_id ON public.resort_info USING btree (id);


--
-- Name: ix_restock_alerts_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_restock_alerts_id ON public.restock_alerts USING btree (id);


--
-- Name: ix_reviews_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_reviews_id ON public.reviews USING btree (id);


--
-- Name: ix_roles_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_roles_id ON public.roles USING btree (id);


--
-- Name: ix_room_assets_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_room_assets_id ON public.room_assets USING btree (id);


--
-- Name: ix_room_consumable_assignments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_room_consumable_assignments_id ON public.room_consumable_assignments USING btree (id);


--
-- Name: ix_room_consumable_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_room_consumable_items_id ON public.room_consumable_items USING btree (id);


--
-- Name: ix_room_inventory_audits_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_room_inventory_audits_id ON public.room_inventory_audits USING btree (id);


--
-- Name: ix_room_inventory_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_room_inventory_items_id ON public.room_inventory_items USING btree (id);


--
-- Name: ix_rooms_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_rooms_id ON public.rooms USING btree (id);


--
-- Name: ix_security_equipment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_security_equipment_id ON public.security_equipment USING btree (id);


--
-- Name: ix_security_maintenance_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_security_maintenance_id ON public.security_maintenance USING btree (id);


--
-- Name: ix_security_uniforms_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_security_uniforms_id ON public.security_uniforms USING btree (id);


--
-- Name: ix_service_images_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_service_images_id ON public.service_images USING btree (id);


--
-- Name: ix_service_requests_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_service_requests_id ON public.service_requests USING btree (id);


--
-- Name: ix_services_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_services_id ON public.services USING btree (id);


--
-- Name: ix_signature_experiences_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_signature_experiences_id ON public.signature_experiences USING btree (id);


--
-- Name: ix_stock_issue_details_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_stock_issue_details_id ON public.stock_issue_details USING btree (id);


--
-- Name: ix_stock_issues_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_stock_issues_id ON public.stock_issues USING btree (id);


--
-- Name: ix_stock_issues_issue_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_stock_issues_issue_number ON public.stock_issues USING btree (issue_number);


--
-- Name: ix_stock_levels_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_stock_levels_id ON public.stock_levels USING btree (id);


--
-- Name: ix_stock_movements_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_stock_movements_id ON public.stock_movements USING btree (id);


--
-- Name: ix_stock_requisition_details_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_stock_requisition_details_id ON public.stock_requisition_details USING btree (id);


--
-- Name: ix_stock_requisitions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_stock_requisitions_id ON public.stock_requisitions USING btree (id);


--
-- Name: ix_stock_requisitions_requisition_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_stock_requisitions_requisition_number ON public.stock_requisitions USING btree (requisition_number);


--
-- Name: ix_stock_usage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_stock_usage_id ON public.stock_usage USING btree (id);


--
-- Name: ix_system_settings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_system_settings_id ON public.system_settings USING btree (id);


--
-- Name: ix_system_settings_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_system_settings_key ON public.system_settings USING btree (key);


--
-- Name: ix_units_of_measurement_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_units_of_measurement_id ON public.units_of_measurement USING btree (id);


--
-- Name: ix_uom_conversions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_uom_conversions_id ON public.uom_conversions USING btree (id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_vendor_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_vendor_items_id ON public.vendor_items USING btree (id);


--
-- Name: ix_vendor_performance_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_vendor_performance_id ON public.vendor_performance USING btree (id);


--
-- Name: ix_vendors_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_vendors_id ON public.vendors USING btree (id);


--
-- Name: ix_vouchers_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_vouchers_id ON public.vouchers USING btree (id);


--
-- Name: ix_wastage_logs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_wastage_logs_id ON public.wastage_logs USING btree (id);


--
-- Name: ix_waste_logs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_waste_logs_id ON public.waste_logs USING btree (id);


--
-- Name: ix_work_order_part_issues_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_work_order_part_issues_id ON public.work_order_part_issues USING btree (id);


--
-- Name: ix_work_order_parts_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_work_order_parts_id ON public.work_order_parts USING btree (id);


--
-- Name: ix_work_orders_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_work_orders_id ON public.work_orders USING btree (id);


--
-- Name: ix_working_logs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_working_logs_id ON public.working_logs USING btree (id);


--
-- Name: recipe_ingredients trigger_set_item_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_set_item_id BEFORE INSERT ON public.recipe_ingredients FOR EACH ROW EXECUTE FUNCTION public.set_item_id_from_inventory_item_id();


--
-- Name: recipe_ingredients trigger_set_uom; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_set_uom BEFORE INSERT OR UPDATE ON public.recipe_ingredients FOR EACH ROW EXECUTE FUNCTION public.set_uom_from_unit();


--
-- Name: account_ledgers account_ledgers_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_ledgers
    ADD CONSTRAINT account_ledgers_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.account_groups(id);


--
-- Name: approval_matrices approval_matrices_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approval_matrices
    ADD CONSTRAINT approval_matrices_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.cost_centers(id);


--
-- Name: approval_requests approval_requests_level_1_approver_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approval_requests
    ADD CONSTRAINT approval_requests_level_1_approver_fkey FOREIGN KEY (level_1_approver) REFERENCES public.users(id);


--
-- Name: approval_requests approval_requests_level_2_approver_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approval_requests
    ADD CONSTRAINT approval_requests_level_2_approver_fkey FOREIGN KEY (level_2_approver) REFERENCES public.users(id);


--
-- Name: approval_requests approval_requests_level_3_approver_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approval_requests
    ADD CONSTRAINT approval_requests_level_3_approver_fkey FOREIGN KEY (level_3_approver) REFERENCES public.users(id);


--
-- Name: approval_requests approval_requests_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approval_requests
    ADD CONSTRAINT approval_requests_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.users(id);


--
-- Name: asset_inspections asset_inspections_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_inspections
    ADD CONSTRAINT asset_inspections_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.room_assets(id);


--
-- Name: asset_inspections asset_inspections_inspected_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_inspections
    ADD CONSTRAINT asset_inspections_inspected_by_fkey FOREIGN KEY (inspected_by) REFERENCES public.users(id);


--
-- Name: asset_maintenance asset_maintenance_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_maintenance
    ADD CONSTRAINT asset_maintenance_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.room_assets(id);


--
-- Name: asset_maintenance asset_maintenance_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_maintenance
    ADD CONSTRAINT asset_maintenance_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.users(id);


--
-- Name: asset_mappings asset_mappings_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_mappings
    ADD CONSTRAINT asset_mappings_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- Name: asset_mappings asset_mappings_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_mappings
    ADD CONSTRAINT asset_mappings_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: asset_mappings asset_mappings_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_mappings
    ADD CONSTRAINT asset_mappings_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: asset_registry asset_registry_current_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_registry
    ADD CONSTRAINT asset_registry_current_location_id_fkey FOREIGN KEY (current_location_id) REFERENCES public.locations(id);


--
-- Name: asset_registry asset_registry_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_registry
    ADD CONSTRAINT asset_registry_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: asset_registry asset_registry_purchase_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_registry
    ADD CONSTRAINT asset_registry_purchase_master_id_fkey FOREIGN KEY (purchase_master_id) REFERENCES public.purchase_masters(id);


--
-- Name: assigned_services assigned_services_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assigned_services
    ADD CONSTRAINT assigned_services_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: assigned_services assigned_services_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assigned_services
    ADD CONSTRAINT assigned_services_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: assigned_services assigned_services_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assigned_services
    ADD CONSTRAINT assigned_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: attendances attendances_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT attendances_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: audit_discrepancies audit_discrepancies_audit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_discrepancies
    ADD CONSTRAINT audit_discrepancies_audit_id_fkey FOREIGN KEY (audit_id) REFERENCES public.eod_audits(id);


--
-- Name: audit_discrepancies audit_discrepancies_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_discrepancies
    ADD CONSTRAINT audit_discrepancies_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: audit_discrepancies audit_discrepancies_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_discrepancies
    ADD CONSTRAINT audit_discrepancies_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: audit_discrepancies audit_discrepancies_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_discrepancies
    ADD CONSTRAINT audit_discrepancies_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.users(id);


--
-- Name: booking_rooms booking_rooms_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_rooms
    ADD CONSTRAINT booking_rooms_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id);


--
-- Name: booking_rooms booking_rooms_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_rooms
    ADD CONSTRAINT booking_rooms_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: checklist_executions checklist_executions_checklist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_executions
    ADD CONSTRAINT checklist_executions_checklist_id_fkey FOREIGN KEY (checklist_id) REFERENCES public.checklists(id);


--
-- Name: checklist_executions checklist_executions_executed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_executions
    ADD CONSTRAINT checklist_executions_executed_by_fkey FOREIGN KEY (executed_by) REFERENCES public.users(id);


--
-- Name: checklist_executions checklist_executions_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_executions
    ADD CONSTRAINT checklist_executions_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: checklist_executions checklist_executions_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_executions
    ADD CONSTRAINT checklist_executions_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: checklist_items checklist_items_checklist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT checklist_items_checklist_id_fkey FOREIGN KEY (checklist_id) REFERENCES public.checklists(id);


--
-- Name: checklist_responses checklist_responses_execution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_responses
    ADD CONSTRAINT checklist_responses_execution_id_fkey FOREIGN KEY (execution_id) REFERENCES public.checklist_executions(id);


--
-- Name: checklist_responses checklist_responses_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_responses
    ADD CONSTRAINT checklist_responses_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.checklist_items(id);


--
-- Name: checklist_responses checklist_responses_responded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_responses
    ADD CONSTRAINT checklist_responses_responded_by_fkey FOREIGN KEY (responded_by) REFERENCES public.users(id);


--
-- Name: checkout_payments checkout_payments_checkout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_payments
    ADD CONSTRAINT checkout_payments_checkout_id_fkey FOREIGN KEY (checkout_id) REFERENCES public.checkouts(id);


--
-- Name: checkout_requests checkout_requests_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_requests
    ADD CONSTRAINT checkout_requests_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id);


--
-- Name: checkout_requests checkout_requests_checkout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_requests
    ADD CONSTRAINT checkout_requests_checkout_id_fkey FOREIGN KEY (checkout_id) REFERENCES public.checkouts(id);


--
-- Name: checkout_requests checkout_requests_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_requests
    ADD CONSTRAINT checkout_requests_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: checkout_requests checkout_requests_package_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_requests
    ADD CONSTRAINT checkout_requests_package_booking_id_fkey FOREIGN KEY (package_booking_id) REFERENCES public.package_bookings(id);


--
-- Name: checkout_verifications checkout_verifications_checkout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_verifications
    ADD CONSTRAINT checkout_verifications_checkout_id_fkey FOREIGN KEY (checkout_id) REFERENCES public.checkouts(id);


--
-- Name: checkout_verifications checkout_verifications_checkout_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_verifications
    ADD CONSTRAINT checkout_verifications_checkout_request_id_fkey FOREIGN KEY (checkout_request_id) REFERENCES public.checkout_requests(id);


--
-- Name: checkouts checkouts_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts
    ADD CONSTRAINT checkouts_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id);


--
-- Name: checkouts checkouts_package_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkouts
    ADD CONSTRAINT checkouts_package_booking_id_fkey FOREIGN KEY (package_booking_id) REFERENCES public.package_bookings(id);


--
-- Name: consumable_usage consumable_usage_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumable_usage
    ADD CONSTRAINT consumable_usage_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id);


--
-- Name: consumable_usage consumable_usage_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumable_usage
    ADD CONSTRAINT consumable_usage_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: consumable_usage consumable_usage_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumable_usage
    ADD CONSTRAINT consumable_usage_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.users(id);


--
-- Name: consumable_usage consumable_usage_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumable_usage
    ADD CONSTRAINT consumable_usage_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: damage_reports damage_reports_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_reports
    ADD CONSTRAINT damage_reports_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: damage_reports damage_reports_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_reports
    ADD CONSTRAINT damage_reports_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: damage_reports damage_reports_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_reports
    ADD CONSTRAINT damage_reports_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: damage_reports damage_reports_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_reports
    ADD CONSTRAINT damage_reports_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: damage_reports damage_reports_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_reports
    ADD CONSTRAINT damage_reports_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: employee_inventory_assignments employee_inventory_assignments_assigned_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_inventory_assignments
    ADD CONSTRAINT employee_inventory_assignments_assigned_service_id_fkey FOREIGN KEY (assigned_service_id) REFERENCES public.assigned_services(id);


--
-- Name: employee_inventory_assignments employee_inventory_assignments_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_inventory_assignments
    ADD CONSTRAINT employee_inventory_assignments_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: employee_inventory_assignments employee_inventory_assignments_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_inventory_assignments
    ADD CONSTRAINT employee_inventory_assignments_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: employees employees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: eod_audit_items eod_audit_items_audit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eod_audit_items
    ADD CONSTRAINT eod_audit_items_audit_id_fkey FOREIGN KEY (audit_id) REFERENCES public.eod_audits(id);


--
-- Name: eod_audit_items eod_audit_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eod_audit_items
    ADD CONSTRAINT eod_audit_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: eod_audits eod_audits_audited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eod_audits
    ADD CONSTRAINT eod_audits_audited_by_fkey FOREIGN KEY (audited_by) REFERENCES public.users(id);


--
-- Name: eod_audits eod_audits_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eod_audits
    ADD CONSTRAINT eod_audits_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: expenses expenses_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: expiry_alerts expiry_alerts_acknowledged_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expiry_alerts
    ADD CONSTRAINT expiry_alerts_acknowledged_by_fkey FOREIGN KEY (acknowledged_by) REFERENCES public.users(id);


--
-- Name: expiry_alerts expiry_alerts_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expiry_alerts
    ADD CONSTRAINT expiry_alerts_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: expiry_alerts expiry_alerts_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expiry_alerts
    ADD CONSTRAINT expiry_alerts_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: fire_safety_equipment fire_safety_equipment_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_equipment
    ADD CONSTRAINT fire_safety_equipment_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: fire_safety_equipment fire_safety_equipment_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_equipment
    ADD CONSTRAINT fire_safety_equipment_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: fire_safety_incidents fire_safety_incidents_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_incidents
    ADD CONSTRAINT fire_safety_incidents_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.fire_safety_equipment(id);


--
-- Name: fire_safety_incidents fire_safety_incidents_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_incidents
    ADD CONSTRAINT fire_safety_incidents_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: fire_safety_incidents fire_safety_incidents_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_incidents
    ADD CONSTRAINT fire_safety_incidents_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: fire_safety_inspections fire_safety_inspections_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_inspections
    ADD CONSTRAINT fire_safety_inspections_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.fire_safety_equipment(id);


--
-- Name: fire_safety_inspections fire_safety_inspections_inspected_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_inspections
    ADD CONSTRAINT fire_safety_inspections_inspected_by_fkey FOREIGN KEY (inspected_by) REFERENCES public.users(id);


--
-- Name: fire_safety_maintenance fire_safety_maintenance_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_maintenance
    ADD CONSTRAINT fire_safety_maintenance_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.fire_safety_equipment(id);


--
-- Name: fire_safety_maintenance fire_safety_maintenance_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fire_safety_maintenance
    ADD CONSTRAINT fire_safety_maintenance_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.users(id);


--
-- Name: first_aid_kit_items first_aid_kit_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_aid_kit_items
    ADD CONSTRAINT first_aid_kit_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: first_aid_kit_items first_aid_kit_items_kit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_aid_kit_items
    ADD CONSTRAINT first_aid_kit_items_kit_id_fkey FOREIGN KEY (kit_id) REFERENCES public.first_aid_kits(id);


--
-- Name: first_aid_kits first_aid_kits_checked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_aid_kits
    ADD CONSTRAINT first_aid_kits_checked_by_fkey FOREIGN KEY (checked_by) REFERENCES public.users(id);


--
-- Name: first_aid_kits first_aid_kits_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_aid_kits
    ADD CONSTRAINT first_aid_kits_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: expenses fk_expenses_vendor_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT fk_expenses_vendor_id FOREIGN KEY (vendor_id) REFERENCES public.vendors(id) ON DELETE SET NULL;


--
-- Name: purchase_masters fk_purchase_masters_destination_location_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_masters
    ADD CONSTRAINT fk_purchase_masters_destination_location_id FOREIGN KEY (destination_location_id) REFERENCES public.locations(id);


--
-- Name: recipe_ingredients fk_recipe_ingredients_inventory_item; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT fk_recipe_ingredients_inventory_item FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_items(id) ON DELETE CASCADE;


--
-- Name: stock_issues fk_stock_issues_dest_location; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issues
    ADD CONSTRAINT fk_stock_issues_dest_location FOREIGN KEY (destination_location_id) REFERENCES public.locations(id);


--
-- Name: stock_issues fk_stock_issues_source_location; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issues
    ADD CONSTRAINT fk_stock_issues_source_location FOREIGN KEY (source_location_id) REFERENCES public.locations(id);


--
-- Name: waste_logs fk_waste_logs_food_item_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waste_logs
    ADD CONSTRAINT fk_waste_logs_food_item_id FOREIGN KEY (food_item_id) REFERENCES public.food_items(id);


--
-- Name: waste_logs fk_waste_logs_location; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waste_logs
    ADD CONSTRAINT fk_waste_logs_location FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: food_item_images food_item_images_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_item_images
    ADD CONSTRAINT food_item_images_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.food_items(id);


--
-- Name: food_items food_items_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_items
    ADD CONSTRAINT food_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.food_categories(id);


--
-- Name: food_order_items food_order_items_food_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_order_items
    ADD CONSTRAINT food_order_items_food_item_id_fkey FOREIGN KEY (food_item_id) REFERENCES public.food_items(id);


--
-- Name: food_order_items food_order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_order_items
    ADD CONSTRAINT food_order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.food_orders(id);


--
-- Name: food_orders food_orders_assigned_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_orders
    ADD CONSTRAINT food_orders_assigned_employee_id_fkey FOREIGN KEY (assigned_employee_id) REFERENCES public.employees(id);


--
-- Name: food_orders food_orders_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.food_orders
    ADD CONSTRAINT food_orders_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: goods_received_notes goods_received_notes_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.purchase_orders(id);


--
-- Name: goods_received_notes goods_received_notes_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.users(id);


--
-- Name: goods_received_notes goods_received_notes_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.users(id);


--
-- Name: grn_items grn_items_grn_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_grn_id_fkey FOREIGN KEY (grn_id) REFERENCES public.goods_received_notes(id);


--
-- Name: grn_items grn_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: grn_items grn_items_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: grn_items grn_items_po_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_po_item_id_fkey FOREIGN KEY (po_item_id) REFERENCES public.po_items(id);


--
-- Name: indent_items indent_items_indent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indent_items
    ADD CONSTRAINT indent_items_indent_id_fkey FOREIGN KEY (indent_id) REFERENCES public.indents(id);


--
-- Name: indent_items indent_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indent_items
    ADD CONSTRAINT indent_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: indents indents_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indents
    ADD CONSTRAINT indents_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: indents indents_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indents
    ADD CONSTRAINT indents_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.users(id);


--
-- Name: indents indents_requested_from_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indents
    ADD CONSTRAINT indents_requested_from_location_id_fkey FOREIGN KEY (requested_from_location_id) REFERENCES public.locations(id);


--
-- Name: indents indents_requested_to_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indents
    ADD CONSTRAINT indents_requested_to_location_id_fkey FOREIGN KEY (requested_to_location_id) REFERENCES public.locations(id);


--
-- Name: inventory_expenses inventory_expenses_cost_center_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_expenses
    ADD CONSTRAINT inventory_expenses_cost_center_id_fkey FOREIGN KEY (cost_center_id) REFERENCES public.cost_centers(id);


--
-- Name: inventory_expenses inventory_expenses_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_expenses
    ADD CONSTRAINT inventory_expenses_issued_by_fkey FOREIGN KEY (issued_by) REFERENCES public.users(id);


--
-- Name: inventory_expenses inventory_expenses_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_expenses
    ADD CONSTRAINT inventory_expenses_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: inventory_items inventory_items_base_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_base_uom_id_fkey FOREIGN KEY (base_uom_id) REFERENCES public.units_of_measurement(id);


--
-- Name: inventory_items inventory_items_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.inventory_categories(id);


--
-- Name: inventory_transactions inventory_transactions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: inventory_transactions inventory_transactions_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: inventory_transactions inventory_transactions_purchase_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_purchase_master_id_fkey FOREIGN KEY (purchase_master_id) REFERENCES public.purchase_masters(id);


--
-- Name: journal_entries journal_entries_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: journal_entries journal_entries_reversed_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_reversed_entry_id_fkey FOREIGN KEY (reversed_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: journal_entry_lines journal_entry_lines_credit_ledger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entry_lines
    ADD CONSTRAINT journal_entry_lines_credit_ledger_id_fkey FOREIGN KEY (credit_ledger_id) REFERENCES public.account_ledgers(id);


--
-- Name: journal_entry_lines journal_entry_lines_debit_ledger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entry_lines
    ADD CONSTRAINT journal_entry_lines_debit_ledger_id_fkey FOREIGN KEY (debit_ledger_id) REFERENCES public.account_ledgers(id);


--
-- Name: journal_entry_lines journal_entry_lines_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entry_lines
    ADD CONSTRAINT journal_entry_lines_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.journal_entries(id);


--
-- Name: key_management key_management_current_holder_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_management
    ADD CONSTRAINT key_management_current_holder_fkey FOREIGN KEY (current_holder) REFERENCES public.users(id);


--
-- Name: key_management key_management_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_management
    ADD CONSTRAINT key_management_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: key_management key_management_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_management
    ADD CONSTRAINT key_management_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: key_movements key_movements_from_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_movements
    ADD CONSTRAINT key_movements_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES public.users(id);


--
-- Name: key_movements key_movements_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_movements
    ADD CONSTRAINT key_movements_key_id_fkey FOREIGN KEY (key_id) REFERENCES public.key_management(id);


--
-- Name: key_movements key_movements_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_movements
    ADD CONSTRAINT key_movements_to_user_id_fkey FOREIGN KEY (to_user_id) REFERENCES public.users(id);


--
-- Name: laundry_services laundry_services_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.laundry_services
    ADD CONSTRAINT laundry_services_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id);


--
-- Name: leaves leaves_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaves
    ADD CONSTRAINT leaves_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: linen_items linen_items_current_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_items
    ADD CONSTRAINT linen_items_current_location_id_fkey FOREIGN KEY (current_location_id) REFERENCES public.locations(id);


--
-- Name: linen_items linen_items_current_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_items
    ADD CONSTRAINT linen_items_current_room_id_fkey FOREIGN KEY (current_room_id) REFERENCES public.rooms(id);


--
-- Name: linen_items linen_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_items
    ADD CONSTRAINT linen_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: linen_movements linen_movements_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_movements
    ADD CONSTRAINT linen_movements_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: linen_movements linen_movements_moved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_movements
    ADD CONSTRAINT linen_movements_moved_by_fkey FOREIGN KEY (moved_by) REFERENCES public.users(id);


--
-- Name: linen_movements linen_movements_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_movements
    ADD CONSTRAINT linen_movements_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: linen_stocks linen_stocks_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_stocks
    ADD CONSTRAINT linen_stocks_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: linen_stocks linen_stocks_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_stocks
    ADD CONSTRAINT linen_stocks_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: linen_wash_logs linen_wash_logs_linen_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linen_wash_logs
    ADD CONSTRAINT linen_wash_logs_linen_item_id_fkey FOREIGN KEY (linen_item_id) REFERENCES public.linen_items(id);


--
-- Name: location_stocks location_stocks_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_stocks
    ADD CONSTRAINT location_stocks_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: location_stocks location_stocks_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_stocks
    ADD CONSTRAINT location_stocks_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: locations locations_parent_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_parent_location_id_fkey FOREIGN KEY (parent_location_id) REFERENCES public.locations(id);


--
-- Name: lost_found lost_found_found_by_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lost_found
    ADD CONSTRAINT lost_found_found_by_employee_id_fkey FOREIGN KEY (found_by_employee_id) REFERENCES public.employees(id);


--
-- Name: maintenance_tickets maintenance_tickets_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT maintenance_tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: maintenance_tickets maintenance_tickets_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT maintenance_tickets_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: maintenance_tickets maintenance_tickets_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT maintenance_tickets_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: maintenance_tickets maintenance_tickets_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT maintenance_tickets_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: maintenance_tickets maintenance_tickets_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT maintenance_tickets_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: office_inventory_items office_inventory_items_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_inventory_items
    ADD CONSTRAINT office_inventory_items_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: office_inventory_items office_inventory_items_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_inventory_items
    ADD CONSTRAINT office_inventory_items_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.cost_centers(id);


--
-- Name: office_inventory_items office_inventory_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_inventory_items
    ADD CONSTRAINT office_inventory_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: office_inventory_items office_inventory_items_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_inventory_items
    ADD CONSTRAINT office_inventory_items_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: office_requisitions office_requisitions_admin_approval_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_requisitions
    ADD CONSTRAINT office_requisitions_admin_approval_fkey FOREIGN KEY (admin_approval) REFERENCES public.users(id);


--
-- Name: office_requisitions office_requisitions_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_requisitions
    ADD CONSTRAINT office_requisitions_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.cost_centers(id);


--
-- Name: office_requisitions office_requisitions_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_requisitions
    ADD CONSTRAINT office_requisitions_issued_by_fkey FOREIGN KEY (issued_by) REFERENCES public.users(id);


--
-- Name: office_requisitions office_requisitions_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_requisitions
    ADD CONSTRAINT office_requisitions_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.office_inventory_items(id);


--
-- Name: office_requisitions office_requisitions_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_requisitions
    ADD CONSTRAINT office_requisitions_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.users(id);


--
-- Name: office_requisitions office_requisitions_supervisor_approval_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_requisitions
    ADD CONSTRAINT office_requisitions_supervisor_approval_fkey FOREIGN KEY (supervisor_approval) REFERENCES public.users(id);


--
-- Name: outlet_stocks outlet_stocks_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outlet_stocks
    ADD CONSTRAINT outlet_stocks_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: outlet_stocks outlet_stocks_outlet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outlet_stocks
    ADD CONSTRAINT outlet_stocks_outlet_id_fkey FOREIGN KEY (outlet_id) REFERENCES public.outlets(id);


--
-- Name: outlets outlets_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outlets
    ADD CONSTRAINT outlets_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: package_booking_rooms package_booking_rooms_package_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_booking_rooms
    ADD CONSTRAINT package_booking_rooms_package_booking_id_fkey FOREIGN KEY (package_booking_id) REFERENCES public.package_bookings(id) ON DELETE CASCADE;


--
-- Name: package_booking_rooms package_booking_rooms_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_booking_rooms
    ADD CONSTRAINT package_booking_rooms_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: package_bookings package_bookings_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_bookings
    ADD CONSTRAINT package_bookings_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.packages(id);


--
-- Name: package_bookings package_bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_bookings
    ADD CONSTRAINT package_bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: package_images package_images_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_images
    ADD CONSTRAINT package_images_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.packages(id);


--
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id);


--
-- Name: perishable_batches perishable_batches_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perishable_batches
    ADD CONSTRAINT perishable_batches_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: perishable_batches perishable_batches_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perishable_batches
    ADD CONSTRAINT perishable_batches_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: po_items po_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.po_items
    ADD CONSTRAINT po_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: po_items po_items_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.po_items
    ADD CONSTRAINT po_items_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.purchase_orders(id);


--
-- Name: purchase_details purchase_details_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_details
    ADD CONSTRAINT purchase_details_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: purchase_details purchase_details_purchase_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_details
    ADD CONSTRAINT purchase_details_purchase_master_id_fkey FOREIGN KEY (purchase_master_id) REFERENCES public.purchase_masters(id);


--
-- Name: purchase_entries purchase_entries_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entries
    ADD CONSTRAINT purchase_entries_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: purchase_entries purchase_entries_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entries
    ADD CONSTRAINT purchase_entries_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: purchase_entries purchase_entries_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entries
    ADD CONSTRAINT purchase_entries_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id);


--
-- Name: purchase_entry_items purchase_entry_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entry_items
    ADD CONSTRAINT purchase_entry_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: purchase_entry_items purchase_entry_items_purchase_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entry_items
    ADD CONSTRAINT purchase_entry_items_purchase_entry_id_fkey FOREIGN KEY (purchase_entry_id) REFERENCES public.purchase_entries(id);


--
-- Name: purchase_entry_items purchase_entry_items_stock_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_entry_items
    ADD CONSTRAINT purchase_entry_items_stock_level_id_fkey FOREIGN KEY (stock_level_id) REFERENCES public.stock_levels(id);


--
-- Name: purchase_masters purchase_masters_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_masters
    ADD CONSTRAINT purchase_masters_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: purchase_masters purchase_masters_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_masters
    ADD CONSTRAINT purchase_masters_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id);


--
-- Name: purchase_orders purchase_orders_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: purchase_orders purchase_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: purchase_orders purchase_orders_indent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_indent_id_fkey FOREIGN KEY (indent_id) REFERENCES public.indents(id);


--
-- Name: recipe_ingredients recipe_ingredients_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: recipe_ingredients recipe_ingredients_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);


--
-- Name: recipes recipes_food_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_food_item_id_fkey FOREIGN KEY (food_item_id) REFERENCES public.food_items(id);


--
-- Name: restock_alerts restock_alerts_acknowledged_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restock_alerts
    ADD CONSTRAINT restock_alerts_acknowledged_by_fkey FOREIGN KEY (acknowledged_by) REFERENCES public.users(id);


--
-- Name: restock_alerts restock_alerts_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restock_alerts
    ADD CONSTRAINT restock_alerts_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: restock_alerts restock_alerts_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restock_alerts
    ADD CONSTRAINT restock_alerts_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: restock_alerts restock_alerts_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restock_alerts
    ADD CONSTRAINT restock_alerts_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.users(id);


--
-- Name: room_assets room_assets_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_assets
    ADD CONSTRAINT room_assets_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: room_assets room_assets_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_assets
    ADD CONSTRAINT room_assets_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: room_consumable_assignments room_consumable_assignments_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_consumable_assignments
    ADD CONSTRAINT room_consumable_assignments_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- Name: room_consumable_assignments room_consumable_assignments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_consumable_assignments
    ADD CONSTRAINT room_consumable_assignments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id);


--
-- Name: room_consumable_assignments room_consumable_assignments_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_consumable_assignments
    ADD CONSTRAINT room_consumable_assignments_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: room_consumable_items room_consumable_items_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_consumable_items
    ADD CONSTRAINT room_consumable_items_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.room_consumable_assignments(id);


--
-- Name: room_consumable_items room_consumable_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_consumable_items
    ADD CONSTRAINT room_consumable_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: room_inventory_audits room_inventory_audits_audited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_audits
    ADD CONSTRAINT room_inventory_audits_audited_by_fkey FOREIGN KEY (audited_by) REFERENCES public.users(id);


--
-- Name: room_inventory_audits room_inventory_audits_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_audits
    ADD CONSTRAINT room_inventory_audits_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: room_inventory_audits room_inventory_audits_room_inventory_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_audits
    ADD CONSTRAINT room_inventory_audits_room_inventory_item_id_fkey FOREIGN KEY (room_inventory_item_id) REFERENCES public.room_inventory_items(id);


--
-- Name: room_inventory_items room_inventory_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_items
    ADD CONSTRAINT room_inventory_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: room_inventory_items room_inventory_items_last_audited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_items
    ADD CONSTRAINT room_inventory_items_last_audited_by_fkey FOREIGN KEY (last_audited_by) REFERENCES public.users(id);


--
-- Name: room_inventory_items room_inventory_items_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_inventory_items
    ADD CONSTRAINT room_inventory_items_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: rooms rooms_inventory_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_inventory_location_id_fkey FOREIGN KEY (inventory_location_id) REFERENCES public.locations(id);


--
-- Name: security_equipment security_equipment_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_equipment
    ADD CONSTRAINT security_equipment_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: security_equipment security_equipment_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_equipment
    ADD CONSTRAINT security_equipment_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: security_equipment security_equipment_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_equipment
    ADD CONSTRAINT security_equipment_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: security_maintenance security_maintenance_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_maintenance
    ADD CONSTRAINT security_maintenance_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.security_equipment(id);


--
-- Name: security_maintenance security_maintenance_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_maintenance
    ADD CONSTRAINT security_maintenance_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.users(id);


--
-- Name: security_uniforms security_uniforms_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_uniforms
    ADD CONSTRAINT security_uniforms_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.users(id);


--
-- Name: security_uniforms security_uniforms_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_uniforms
    ADD CONSTRAINT security_uniforms_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: service_images service_images_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_images
    ADD CONSTRAINT service_images_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: service_inventory_items service_inventory_items_inventory_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_inventory_items
    ADD CONSTRAINT service_inventory_items_inventory_item_id_fkey FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_items(id);


--
-- Name: service_inventory_items service_inventory_items_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_inventory_items
    ADD CONSTRAINT service_inventory_items_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: service_requests service_requests_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_requests
    ADD CONSTRAINT service_requests_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: service_requests service_requests_food_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_requests
    ADD CONSTRAINT service_requests_food_order_id_fkey FOREIGN KEY (food_order_id) REFERENCES public.food_orders(id);


--
-- Name: service_requests service_requests_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_requests
    ADD CONSTRAINT service_requests_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id);


--
-- Name: stock_issue_details stock_issue_details_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issue_details
    ADD CONSTRAINT stock_issue_details_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES public.stock_issues(id);


--
-- Name: stock_issue_details stock_issue_details_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issue_details
    ADD CONSTRAINT stock_issue_details_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: stock_issues stock_issues_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issues
    ADD CONSTRAINT stock_issues_issued_by_fkey FOREIGN KEY (issued_by) REFERENCES public.users(id);


--
-- Name: stock_issues stock_issues_requisition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_issues
    ADD CONSTRAINT stock_issues_requisition_id_fkey FOREIGN KEY (requisition_id) REFERENCES public.stock_requisitions(id);


--
-- Name: stock_levels stock_levels_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_levels
    ADD CONSTRAINT stock_levels_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: stock_levels stock_levels_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_levels
    ADD CONSTRAINT stock_levels_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: stock_movements stock_movements_from_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_from_location_id_fkey FOREIGN KEY (from_location_id) REFERENCES public.locations(id);


--
-- Name: stock_movements stock_movements_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: stock_movements stock_movements_moved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_moved_by_fkey FOREIGN KEY (moved_by) REFERENCES public.users(id);


--
-- Name: stock_movements stock_movements_to_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_to_location_id_fkey FOREIGN KEY (to_location_id) REFERENCES public.locations(id);


--
-- Name: stock_requisition_details stock_requisition_details_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_requisition_details
    ADD CONSTRAINT stock_requisition_details_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: stock_requisition_details stock_requisition_details_requisition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_requisition_details
    ADD CONSTRAINT stock_requisition_details_requisition_id_fkey FOREIGN KEY (requisition_id) REFERENCES public.stock_requisitions(id);


--
-- Name: stock_requisitions stock_requisitions_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_requisitions
    ADD CONSTRAINT stock_requisitions_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: stock_requisitions stock_requisitions_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_requisitions
    ADD CONSTRAINT stock_requisitions_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.users(id);


--
-- Name: stock_usage stock_usage_food_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_usage
    ADD CONSTRAINT stock_usage_food_order_id_fkey FOREIGN KEY (food_order_id) REFERENCES public.food_orders(id);


--
-- Name: stock_usage stock_usage_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_usage
    ADD CONSTRAINT stock_usage_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: stock_usage stock_usage_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_usage
    ADD CONSTRAINT stock_usage_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: stock_usage stock_usage_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_usage
    ADD CONSTRAINT stock_usage_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);


--
-- Name: stock_usage stock_usage_used_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_usage
    ADD CONSTRAINT stock_usage_used_by_fkey FOREIGN KEY (used_by) REFERENCES public.users(id);


--
-- Name: uom_conversions uom_conversions_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uom_conversions
    ADD CONSTRAINT uom_conversions_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: vendor_items vendor_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_items
    ADD CONSTRAINT vendor_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: vendor_items vendor_items_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_items
    ADD CONSTRAINT vendor_items_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id);


--
-- Name: vendor_performance vendor_performance_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_performance
    ADD CONSTRAINT vendor_performance_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id);


--
-- Name: wastage_logs wastage_logs_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wastage_logs
    ADD CONSTRAINT wastage_logs_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: wastage_logs wastage_logs_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wastage_logs
    ADD CONSTRAINT wastage_logs_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: wastage_logs wastage_logs_logged_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wastage_logs
    ADD CONSTRAINT wastage_logs_logged_by_fkey FOREIGN KEY (logged_by) REFERENCES public.users(id);


--
-- Name: waste_logs waste_logs_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waste_logs
    ADD CONSTRAINT waste_logs_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: waste_logs waste_logs_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waste_logs
    ADD CONSTRAINT waste_logs_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: work_order_part_issues work_order_part_issues_from_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_part_issues
    ADD CONSTRAINT work_order_part_issues_from_location_id_fkey FOREIGN KEY (from_location_id) REFERENCES public.locations(id);


--
-- Name: work_order_part_issues work_order_part_issues_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_part_issues
    ADD CONSTRAINT work_order_part_issues_issued_by_fkey FOREIGN KEY (issued_by) REFERENCES public.users(id);


--
-- Name: work_order_part_issues work_order_part_issues_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_part_issues
    ADD CONSTRAINT work_order_part_issues_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: work_order_part_issues work_order_part_issues_work_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_part_issues
    ADD CONSTRAINT work_order_part_issues_work_order_id_fkey FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: work_order_parts work_order_parts_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_parts
    ADD CONSTRAINT work_order_parts_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory_items(id);


--
-- Name: work_order_parts work_order_parts_work_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_parts
    ADD CONSTRAINT work_order_parts_work_order_id_fkey FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: work_orders work_orders_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.room_assets(id);


--
-- Name: work_orders work_orders_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: work_orders work_orders_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: working_logs working_logs_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.working_logs
    ADD CONSTRAINT working_logs_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- PostgreSQL database dump complete
--

