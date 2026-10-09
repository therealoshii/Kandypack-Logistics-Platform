package com.kandypack.logistics.report.service;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.kandypack.logistics.fleet.dto.FleetUsageDTO;
import com.kandypack.logistics.report.dto.CustomerOrderHistoryDTO;
import com.kandypack.logistics.report.dto.GeographicSalesReportDTO;
import com.kandypack.logistics.report.dto.QuarterlyReportDTO;
import com.kandypack.logistics.report.dto.TopItemsDTO;
import com.kandypack.logistics.report.dto.WorkingHoursReportDTO;

class ReportPdfServiceTest {

    private ReportPdfService reportPdfService;

    @BeforeEach
    void setUp() {
        reportPdfService = new ReportPdfService();
    }

    private void assertValidPdf(byte[] pdfBytes) {
        assertNotNull(pdfBytes);
        assertTrue(pdfBytes.length > 50, "PDF should not be empty");
        // PDF magic bytes: %PDF-
        String header = new String(pdfBytes, 0, Math.min(5, pdfBytes.length));
        assertTrue(header.startsWith("%PDF"), "Output must start with PDF header marker");
    }

    @Test
    void generatesQuarterlySalesPdfSuccessfully() {
        List<QuarterlyReportDTO> data = List.of(
                new QuarterlyReportDTO(2026, 1, 15L, 450L, BigDecimal.valueOf(125.5), BigDecimal.valueOf(350000.00)),
                new QuarterlyReportDTO(2026, 2, 25L, 780L, BigDecimal.valueOf(210.0), BigDecimal.valueOf(520000.00))
        );
        byte[] pdf = reportPdfService.generateQuarterlySalesPdf(data, 2026, null);
        assertValidPdf(pdf);
    }

    @Test
    void generatesTopItemsPdfSuccessfully() {
        List<TopItemsDTO> data = List.of(
                new TopItemsDTO(1, "Kandypack Detergent Powder 1kg", "Cleaning", BigDecimal.valueOf(450.00), 200L, BigDecimal.valueOf(90000.00), 12L),
                new TopItemsDTO(2, "Ceylon Tea 500g", "Beverages", BigDecimal.valueOf(380.00), 150L, BigDecimal.valueOf(57000.00), 10L)
        );
        byte[] pdf = reportPdfService.generateTopItemsPdf(data, 2026, 3, 10);
        assertValidPdf(pdf);
    }

    @Test
    void generatesGeographicSalesPdfSuccessfully() {
        List<GeographicSalesReportDTO> data = List.of(
                new GeographicSalesReportDTO("Colombo", 1, "Colombo Fort Route", 20L, 500L, BigDecimal.valueOf(300000.00)),
                new GeographicSalesReportDTO("Galle", 5, "Galle Coastal Route", 12L, 250L, BigDecimal.valueOf(180000.00))
        );
        byte[] pdf = reportPdfService.generateGeographicSalesPdf(data, LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31));
        assertValidPdf(pdf);
    }

    @Test
    void generatesWorkingHoursPdfSuccessfully() {
        List<WorkingHoursReportDTO> data = List.of(
                new WorkingHoursReportDTO("Driver", 1, "Kamal Perera", "B1234567", 8L, BigDecimal.valueOf(34.5), BigDecimal.valueOf(40.0)),
                new WorkingHoursReportDTO("Assistant", 1, "Sunil Shantha", "0771234567", 10L, BigDecimal.valueOf(52.0), BigDecimal.valueOf(60.0))
        );
        byte[] pdf = reportPdfService.generateWorkingHoursPdf(data, LocalDate.of(2026, 8, 1), LocalDate.of(2026, 8, 31));
        assertValidPdf(pdf);
    }

    @Test
    void generatesFleetUsagePdfSuccessfully() {
        FleetUsageDTO truck = new FleetUsageDTO();
        truck.setTruckID(1);
        truck.setRegistrationNumber("WP-CA-1024");
        truck.setStoreName("Colombo Central Warehouse");
        truck.setCity("Colombo");
        truck.setTotalTrips(14);
        truck.setOperatingHours(56.5);
        truck.setTotalMileage(1620.0);

        byte[] pdf = reportPdfService.generateFleetUsagePdf(List.of(truck), 2026, 8);
        assertValidPdf(pdf);
    }

    @Test
    void generatesCustomerOrderHistoryPdfSuccessfully() {
        List<CustomerOrderHistoryDTO> data = List.of(
                new CustomerOrderHistoryDTO(101, 1, "Lanka Super Center Colombo", LocalDate.of(2026, 8, 12),
                        "Delivered", BigDecimal.valueOf(45000.00), "Colombo Fort Route", "Colombo",
                        501, LocalDate.of(2026, 8, 14), "Completed", 201, "Kamal Perera", "Sunil Shantha",
                        "WP-CA-1024", 5L, 120L)
        );
        byte[] pdf = reportPdfService.generateCustomerOrderHistoryPdf(data, 1);
        assertValidPdf(pdf);
    }
}
