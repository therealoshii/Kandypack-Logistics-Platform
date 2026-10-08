package com.kandypack.logistics.report.service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.springframework.stereotype.Service;

import com.kandypack.logistics.fleet.dto.FleetUsageDTO;
import com.kandypack.logistics.report.dto.CustomerOrderHistoryDTO;
import com.kandypack.logistics.report.dto.GeographicSalesReportDTO;
import com.kandypack.logistics.report.dto.QuarterlyReportDTO;
import com.kandypack.logistics.report.dto.TopItemsDTO;
import com.kandypack.logistics.report.dto.WorkingHoursReportDTO;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPageEventHelper;
import com.lowagie.text.pdf.PdfWriter;

@Service
public class ReportPdfService {

    private static final Color PRIMARY_DARK = new Color(33, 65, 48);
    private static final Color PRIMARY_LIGHT = new Color(244, 247, 244);
    private static final Color HEADER_BG = new Color(45, 75, 58);
    private static final Color ALT_ROW_BG = new Color(250, 252, 250);
    private static final Color BORDER_COLOR = new Color(220, 226, 220);
    private static final Color TEXT_MUTED = new Color(110, 125, 115);
    private static final Color TEXT_DARK = new Color(30, 40, 35);

    private static final Font FONT_TITLE = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, PRIMARY_DARK);
    private static final Font FONT_SUBTITLE = FontFactory.getFont(FontFactory.HELVETICA, 10, TEXT_MUTED);
    private static final Font FONT_META = FontFactory.getFont(FontFactory.HELVETICA, 9, TEXT_DARK);
    private static final Font FONT_TH = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, Color.WHITE);
    private static final Font FONT_TD = FontFactory.getFont(FontFactory.HELVETICA, 8.5f, TEXT_DARK);
    private static final Font FONT_TD_BOLD = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8.5f, TEXT_DARK);
    private static final Font FONT_FOOTER = FontFactory.getFont(FontFactory.HELVETICA, 8, TEXT_MUTED);

    private static final DecimalFormat CURRENCY_FMT = new DecimalFormat("#,##0.00");
    private static final DecimalFormat NUMBER_FMT = new DecimalFormat("#,##0");
    private static final DateTimeFormatter DATE_TIME_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private static class FooterPageEvent extends PdfPageEventHelper {
        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            PdfPTable footer = new PdfPTable(2);
            footer.setTotalWidth(document.right() - document.left());
            footer.setWidthPercentage(100);

            PdfPCell cellLeft = new PdfPCell(new Phrase("Kandypack Logistics Platform · Confidential Management Report", FONT_FOOTER));
            cellLeft.setBorder(Rectangle.TOP);
            cellLeft.setBorderColor(BORDER_COLOR);
            cellLeft.setPaddingTop(5);

            PdfPCell cellRight = new PdfPCell(new Phrase(String.format("Page %d", writer.getPageNumber()), FONT_FOOTER));
            cellRight.setHorizontalAlignment(Element.ALIGN_RIGHT);
            cellRight.setBorder(Rectangle.TOP);
            cellRight.setBorderColor(BORDER_COLOR);
            cellRight.setPaddingTop(5);

            footer.addCell(cellLeft);
            footer.addCell(cellRight);
            footer.writeSelectedRows(0, -1, document.left(), document.bottom() - 10, writer.getDirectContent());
        }
    }

    private void addReportHeader(Document document, String title, String subtitle, String filterInfo) throws Exception {
        Paragraph brand = new Paragraph("KANDYPACK LOGISTICS PLATFORM", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, PRIMARY_DARK));
        brand.setSpacingAfter(2);
        document.add(brand);

        Paragraph pTitle = new Paragraph(title, FONT_TITLE);
        pTitle.setSpacingAfter(4);
        document.add(pTitle);

        if (subtitle != null && !subtitle.isBlank()) {
            Paragraph pSub = new Paragraph(subtitle, FONT_SUBTITLE);
            pSub.setSpacingAfter(8);
            document.add(pSub);
        }

        PdfPTable metaTable = new PdfPTable(2);
        metaTable.setWidthPercentage(100);
        metaTable.setSpacingAfter(14);

        PdfPCell cFilter = new PdfPCell(new Phrase(filterInfo != null ? filterInfo : "All Records", FONT_META));
        cFilter.setBackgroundColor(PRIMARY_LIGHT);
        cFilter.setBorderColor(BORDER_COLOR);
        cFilter.setPadding(6);

        PdfPCell cTime = new PdfPCell(new Phrase("Generated on: " + LocalDateTime.now().format(DATE_TIME_FMT), FONT_META));
        cTime.setBackgroundColor(PRIMARY_LIGHT);
        cTime.setBorderColor(BORDER_COLOR);
        cTime.setHorizontalAlignment(Element.ALIGN_RIGHT);
        cTime.setPadding(6);

        metaTable.addCell(cFilter);
        metaTable.addCell(cTime);
        document.add(metaTable);
    }

    private PdfPCell createHeaderCell(String text, int alignment) {
        PdfPCell cell = new PdfPCell(new Phrase(text, FONT_TH));
        cell.setBackgroundColor(HEADER_BG);
        cell.setBorderColor(BORDER_COLOR);
        cell.setHorizontalAlignment(alignment);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setPadding(6);
        return cell;
    }

    private PdfPCell createDataCell(String text, int alignment, boolean isAlt, boolean isBold) {
        PdfPCell cell = new PdfPCell(new Phrase(text != null ? text : "—", isBold ? FONT_TD_BOLD : FONT_TD));
        cell.setBackgroundColor(isAlt ? ALT_ROW_BG : Color.WHITE);
        cell.setBorderColor(BORDER_COLOR);
        cell.setHorizontalAlignment(alignment);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setPadding(5);
        return cell;
    }

    /**
     * 1. Quarterly sales report (value and volume)
     */
    public byte[] generateQuarterlySalesPdf(List<QuarterlyReportDTO> data, Integer year, Integer quarter) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 36, 36, 40, 40);
        try {
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setPageEvent(new FooterPageEvent());
            document.open();

            String filter = "Report Period: " + (year != null ? "Year " + year : "All Years")
                    + (quarter != null ? " · Quarter " + quarter : " · All Quarters");
            addReportHeader(document, "Quarterly Sales Report", "Comprehensive sales value (LKR) and volume distribution", filter);

            PdfPTable table = new PdfPTable(6);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{1.5f, 1.5f, 2f, 2.2f, 2.2f, 2.8f});

            table.addCell(createHeaderCell("Year", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Quarter", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Total Orders", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Units Sold", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Volume Space (m³)", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Total Revenue (LKR)", Element.ALIGN_RIGHT));

            long sumOrders = 0;
            long sumUnits = 0;
            double sumVolume = 0;
            BigDecimal sumRevenue = BigDecimal.ZERO;

            boolean alt = false;
            for (QuarterlyReportDTO row : data) {
                table.addCell(createDataCell(String.valueOf(row.getYear()), Element.ALIGN_CENTER, alt, false));
                table.addCell(createDataCell("Q" + row.getQuarter(), Element.ALIGN_CENTER, alt, false));
                table.addCell(createDataCell(NUMBER_FMT.format(row.getTotalOrders() != null ? row.getTotalOrders() : 0), Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(NUMBER_FMT.format(row.getTotalUnitsSold() != null ? row.getTotalUnitsSold() : 0), Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(CURRENCY_FMT.format(row.getTotalVolumeSpace() != null ? row.getTotalVolumeSpace().doubleValue() : 0.0), Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(CURRENCY_FMT.format(row.getTotalRevenue() != null ? row.getTotalRevenue() : BigDecimal.ZERO), Element.ALIGN_RIGHT, alt, false));

                if (row.getTotalOrders() != null) sumOrders += row.getTotalOrders();
                if (row.getTotalUnitsSold() != null) sumUnits += row.getTotalUnitsSold();
                if (row.getTotalVolumeSpace() != null) sumVolume += row.getTotalVolumeSpace().doubleValue();
                if (row.getTotalRevenue() != null) sumRevenue = sumRevenue.add(row.getTotalRevenue());
                alt = !alt;
            }

            // Totals Row
            table.addCell(createDataCell("Total", Element.ALIGN_CENTER, true, true));
            table.addCell(createDataCell("—", Element.ALIGN_CENTER, true, true));
            table.addCell(createDataCell(NUMBER_FMT.format(sumOrders), Element.ALIGN_RIGHT, true, true));
            table.addCell(createDataCell(NUMBER_FMT.format(sumUnits), Element.ALIGN_RIGHT, true, true));
            table.addCell(createDataCell(CURRENCY_FMT.format(sumVolume), Element.ALIGN_RIGHT, true, true));
            table.addCell(createDataCell(CURRENCY_FMT.format(sumRevenue), Element.ALIGN_RIGHT, true, true));

            document.add(table);
            document.close();
        } catch (Exception e) {
            throw new RuntimeException("Error generating quarterly sales PDF: " + e.getMessage(), e);
        }
        return out.toByteArray();
    }

    /**
     * 2. Most ordered items in a given quarter
     */
    public byte[] generateTopItemsPdf(List<TopItemsDTO> data, Integer year, Integer quarter, Integer limit) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 36, 36, 40, 40);
        try {
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setPageEvent(new FooterPageEvent());
            document.open();

            String filter = "Period: Year " + year + " · Quarter " + quarter + " | Limit: Top " + (limit != null ? limit : 10) + " Items";
            addReportHeader(document, "Most Ordered Items Report", "High-demand product rankings and revenue contribution", filter);

            PdfPTable table = new PdfPTable(7);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{1.2f, 3.8f, 2.2f, 2f, 2f, 2f, 2.8f});

            table.addCell(createHeaderCell("Rank", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Product Name", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Category", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Unit Price (LKR)", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Orders", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Qty Ordered", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Total Revenue (LKR)", Element.ALIGN_RIGHT));

            int rank = 1;
            boolean alt = false;
            for (TopItemsDTO item : data) {
                table.addCell(createDataCell(String.valueOf(rank++), Element.ALIGN_CENTER, alt, false));
                table.addCell(createDataCell(item.getProductName(), Element.ALIGN_LEFT, alt, true));
                table.addCell(createDataCell(item.getCategory(), Element.ALIGN_LEFT, alt, false));
                table.addCell(createDataCell(item.getUnitPrice() != null ? CURRENCY_FMT.format(item.getUnitPrice()) : "—", Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(item.getDistinctOrdersCount() != null ? NUMBER_FMT.format(item.getDistinctOrdersCount()) : "—", Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(item.getTotalQuantitySold() != null ? NUMBER_FMT.format(item.getTotalQuantitySold()) : "0", Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(item.getTotalRevenueGenerated() != null ? CURRENCY_FMT.format(item.getTotalRevenueGenerated()) : "0.00", Element.ALIGN_RIGHT, alt, false));
                alt = !alt;
            }

            document.add(table);
            document.close();
        } catch (Exception e) {
            throw new RuntimeException("Error generating top items PDF: " + e.getMessage(), e);
        }
        return out.toByteArray();
    }

    /**
     * 3. City-wise and route-wise sales breakdown
     */
    public byte[] generateGeographicSalesPdf(List<GeographicSalesReportDTO> data, LocalDate startDate, LocalDate endDate) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 36, 36, 40, 40);
        try {
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setPageEvent(new FooterPageEvent());
            document.open();

            String filter = "Date Range: " + (startDate != null ? startDate.toString() : "Earliest") + " to " + (endDate != null ? endDate.toString() : "Latest");
            addReportHeader(document, "City-wise & Route-wise Sales Breakdown", "Regional distribution network sales and volume analysis", filter);

            PdfPTable table = new PdfPTable(6);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{2.2f, 1.2f, 4f, 1.8f, 1.8f, 2.6f});

            table.addCell(createHeaderCell("City", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Route ID", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Route Name", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Total Orders", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Total Units", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Total Sales (LKR)", Element.ALIGN_RIGHT));

            long sumOrders = 0;
            long sumUnits = 0;
            BigDecimal sumSales = BigDecimal.ZERO;

            boolean alt = false;
            for (GeographicSalesReportDTO row : data) {
                table.addCell(createDataCell(row.getCity(), Element.ALIGN_LEFT, alt, true));
                table.addCell(createDataCell(row.getRouteId() != null ? "#" + row.getRouteId() : "—", Element.ALIGN_CENTER, alt, false));
                table.addCell(createDataCell(row.getRouteName(), Element.ALIGN_LEFT, alt, false));
                table.addCell(createDataCell(NUMBER_FMT.format(row.getTotalOrders() != null ? row.getTotalOrders() : 0), Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(NUMBER_FMT.format(row.getTotalUnits() != null ? row.getTotalUnits() : 0), Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(CURRENCY_FMT.format(row.getTotalSales() != null ? row.getTotalSales() : BigDecimal.ZERO), Element.ALIGN_RIGHT, alt, false));

                if (row.getTotalOrders() != null) sumOrders += row.getTotalOrders();
                if (row.getTotalUnits() != null) sumUnits += row.getTotalUnits();
                if (row.getTotalSales() != null) sumSales = sumSales.add(row.getTotalSales());
                alt = !alt;
            }

            // Summary row
            table.addCell(createDataCell("Total", Element.ALIGN_LEFT, true, true));
            table.addCell(createDataCell("—", Element.ALIGN_CENTER, true, true));
            table.addCell(createDataCell("All Regional Routes", Element.ALIGN_LEFT, true, true));
            table.addCell(createDataCell(NUMBER_FMT.format(sumOrders), Element.ALIGN_RIGHT, true, true));
            table.addCell(createDataCell(NUMBER_FMT.format(sumUnits), Element.ALIGN_RIGHT, true, true));
            table.addCell(createDataCell(CURRENCY_FMT.format(sumSales), Element.ALIGN_RIGHT, true, true));

            document.add(table);
            document.close();
        } catch (Exception e) {
            throw new RuntimeException("Error generating geographic sales PDF: " + e.getMessage(), e);
        }
        return out.toByteArray();
    }

    /**
     * 4. Driver and assistant working hours report
     */
    public byte[] generateWorkingHoursPdf(List<WorkingHoursReportDTO> data, LocalDate startDate, LocalDate endDate) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 36, 36, 40, 40);
        try {
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setPageEvent(new FooterPageEvent());
            document.open();

            String filter = "Date Range: " + (startDate != null ? startDate.toString() : "All-time") + " to " + (endDate != null ? endDate.toString() : "Present");
            addReportHeader(document, "Driver & Assistant Working Hours Report", "Crew compliance with statutory weekly limits (40h Driver / 60h Assistant)", filter);

            PdfPTable table = new PdfPTable(7);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{1.8f, 1.2f, 3.2f, 2.6f, 1.8f, 2f, 2.2f});

            table.addCell(createHeaderCell("Staff Role", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Staff ID", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Staff Name", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Licence / Contact", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Trips Completed", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Hours Worked", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Weekly Limit", Element.ALIGN_RIGHT));

            boolean alt = false;
            for (WorkingHoursReportDTO staff : data) {
                table.addCell(createDataCell(staff.getStaffRole(), Element.ALIGN_CENTER, alt, true));
                table.addCell(createDataCell("#" + staff.getStaffId(), Element.ALIGN_CENTER, alt, false));
                table.addCell(createDataCell(staff.getStaffName(), Element.ALIGN_LEFT, alt, false));
                table.addCell(createDataCell(staff.getReferenceId(), Element.ALIGN_LEFT, alt, false));
                table.addCell(createDataCell(NUMBER_FMT.format(staff.getTotalTripsCompleted() != null ? staff.getTotalTripsCompleted() : 0), Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(CURRENCY_FMT.format(staff.getTotalHoursWorked() != null ? staff.getTotalHoursWorked() : BigDecimal.ZERO) + " hrs", Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(CURRENCY_FMT.format(staff.getStandardWeeklyLimit() != null ? staff.getStandardWeeklyLimit() : BigDecimal.ZERO) + " hrs/wk", Element.ALIGN_RIGHT, alt, false));
                alt = !alt;
            }

            document.add(table);
            document.close();
        } catch (Exception e) {
            throw new RuntimeException("Error generating working hours PDF: " + e.getMessage(), e);
        }
        return out.toByteArray();
    }

    /**
     * 5. Truck usage analysis per month
     */
    public byte[] generateFleetUsagePdf(List<FleetUsageDTO> data, Integer year, Integer month) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 36, 36, 40, 40);
        try {
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setPageEvent(new FooterPageEvent());
            document.open();

            String filter = "Billing Period: " + year + " - Month " + String.format("%02d", month);
            addReportHeader(document, "Truck Usage & Fleet Analysis Report", "Monthly dispatch trips, operating engine hours, and fleet mileage", filter);

            PdfPTable table = new PdfPTable(7);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{1.2f, 2.5f, 3.5f, 2.2f, 1.8f, 2.4f, 2.4f});

            table.addCell(createHeaderCell("Truck ID", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Plate Reg.", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Store / Warehouse Hub", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Station City", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Trips", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Operating Hours", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Total Mileage (km)", Element.ALIGN_RIGHT));

            long sumTrips = 0;
            double sumHours = 0;
            double sumMileage = 0;

            boolean alt = false;
            for (FleetUsageDTO truck : data) {
                table.addCell(createDataCell("#" + truck.getTruckID(), Element.ALIGN_CENTER, alt, false));
                table.addCell(createDataCell(truck.getRegistrationNumber(), Element.ALIGN_LEFT, alt, true));
                table.addCell(createDataCell(truck.getStoreName(), Element.ALIGN_LEFT, alt, false));
                table.addCell(createDataCell(truck.getCity(), Element.ALIGN_LEFT, alt, false));
                table.addCell(createDataCell(NUMBER_FMT.format(truck.getTotalTrips() != null ? truck.getTotalTrips() : 0), Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(CURRENCY_FMT.format(truck.getOperatingHours() != null ? truck.getOperatingHours() : 0.0) + " hrs", Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(CURRENCY_FMT.format(truck.getTotalMileage() != null ? truck.getTotalMileage() : 0.0) + " km", Element.ALIGN_RIGHT, alt, false));

                if (truck.getTotalTrips() != null) sumTrips += truck.getTotalTrips();
                if (truck.getOperatingHours() != null) sumHours += truck.getOperatingHours();
                if (truck.getTotalMileage() != null) sumMileage += truck.getTotalMileage();
                alt = !alt;
            }

            // Summary
            table.addCell(createDataCell("Total", Element.ALIGN_CENTER, true, true));
            table.addCell(createDataCell("All Trucks", Element.ALIGN_LEFT, true, true));
            table.addCell(createDataCell("—", Element.ALIGN_LEFT, true, true));
            table.addCell(createDataCell("—", Element.ALIGN_LEFT, true, true));
            table.addCell(createDataCell(NUMBER_FMT.format(sumTrips), Element.ALIGN_RIGHT, true, true));
            table.addCell(createDataCell(CURRENCY_FMT.format(sumHours) + " hrs", Element.ALIGN_RIGHT, true, true));
            table.addCell(createDataCell(CURRENCY_FMT.format(sumMileage) + " km", Element.ALIGN_RIGHT, true, true));

            document.add(table);
            document.close();
        } catch (Exception e) {
            throw new RuntimeException("Error generating fleet usage PDF: " + e.getMessage(), e);
        }
        return out.toByteArray();
    }

    /**
     * 6. Customer order history with delivery details
     */
    public byte[] generateCustomerOrderHistoryPdf(List<CustomerOrderHistoryDTO> data, Integer customerId) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        // Use landscape for customer order history because of wide delivery details
        Document document = new Document(PageSize.A4.rotate(), 36, 36, 40, 40);
        try {
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setPageEvent(new FooterPageEvent());
            document.open();

            String customerLabel = (customerId != null && customerId > 0 && !data.isEmpty())
                    ? "Customer #" + customerId + " (" + data.get(0).getCustomerName() + ")"
                    : "All Customers";
            String filter = "Filter: " + customerLabel + " | Total Records: " + data.size();
            addReportHeader(document, "Customer Order History & Delivery Details", "End-to-end customer order fulfillment, delivery statuses, and crew dispatch assignment", filter);

            PdfPTable table = new PdfPTable(10);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{1.4f, 2.8f, 1.8f, 1.8f, 2.5f, 3.2f, 2.2f, 2.4f, 2.4f, 2.2f});

            table.addCell(createHeaderCell("Order ID", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Customer", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Order Date", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Status", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Total (LKR)", Element.ALIGN_RIGHT));
            table.addCell(createHeaderCell("Route / City", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Delivery Date", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Delivery Status", Element.ALIGN_CENTER));
            table.addCell(createHeaderCell("Assigned Crew", Element.ALIGN_LEFT));
            table.addCell(createHeaderCell("Assigned Truck", Element.ALIGN_CENTER));

            boolean alt = false;
            for (CustomerOrderHistoryDTO row : data) {
                table.addCell(createDataCell("#" + row.getOrderId(), Element.ALIGN_CENTER, alt, true));
                table.addCell(createDataCell(row.getCustomerName(), Element.ALIGN_LEFT, alt, false));
                table.addCell(createDataCell(row.getOrderDate() != null ? row.getOrderDate().toString() : "—", Element.ALIGN_CENTER, alt, false));
                table.addCell(createDataCell(row.getOrderStatus(), Element.ALIGN_CENTER, alt, false));
                table.addCell(createDataCell(row.getOrderTotalLKR() != null ? CURRENCY_FMT.format(row.getOrderTotalLKR()) : "0.00", Element.ALIGN_RIGHT, alt, false));
                table.addCell(createDataCell(row.getRouteName() + " (" + row.getDestinationCity() + ")", Element.ALIGN_LEFT, alt, false));
                table.addCell(createDataCell(row.getDeliveryDate() != null ? row.getDeliveryDate().toString() : "Pending", Element.ALIGN_CENTER, alt, false));
                table.addCell(createDataCell(row.getDeliveryStatus(), Element.ALIGN_CENTER, alt, false));

                String crew = (row.getAssignedDriver() != null ? "D: " + row.getAssignedDriver() : "D: Unassigned")
                        + "\n" + (row.getAssignedAssistant() != null ? "A: " + row.getAssignedAssistant() : "A: Unassigned");
                table.addCell(createDataCell(crew, Element.ALIGN_LEFT, alt, false));
                table.addCell(createDataCell(row.getAssignedTruck() != null ? row.getAssignedTruck() : "—", Element.ALIGN_CENTER, alt, false));

                alt = !alt;
            }

            document.add(table);
            document.close();
        } catch (Exception e) {
            throw new RuntimeException("Error generating customer order history PDF: " + e.getMessage(), e);
        }
        return out.toByteArray();
    }
}
