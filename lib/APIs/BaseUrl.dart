const String wifiUrl = "http://3.6.119.57:9090";
// const String wifiUrl = "https://api.aesthetech.life";
// const String wifiUrl = "http://43.205.96.147:9090";

// const String serverUrl = "${wifiUrl}:9090/api";
const String serverUrl = "${wifiUrl}";
const String clinicUrl = "${wifiUrl}/clinic-admin";
const String baseUrl = '$serverUrl/customers';
const String consultationUrl = "${wifiUrl}/api/customer/getAllConsultations";
const String registerUrl = '${wifiUrl}/api/customer';
const String categoryUrl = '${wifiUrl}/admin/getCategories';
const String getServiceByCategoriesID = '${wifiUrl}/admin/getServiceById';
const String getSubServiceByServiceID =
    '${wifiUrl}/admin/getSubServicesByServiceId';
const String getSubServiceByServiceIDHospitalID =
    '${wifiUrl}/clinic-admin/getSubService';
const String getCustomer = '$baseUrl/getCustomer';
const String BookingUrl = '${registerUrl}/bookService';
 