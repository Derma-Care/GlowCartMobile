// const String wifiUrl = "http://3.6.119.57:9090";
const String wifiUrl = "https://api.aesthetech.life";
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

// const String wifiUrl = "192.168.1.5";
// // const String serverUrl = "${wifiUrl}:9090/api";
// const String serverUrl = "${wifiUrl}";
// const String clinicUrl = "${wifiUrl}:8080/clinic-admin";
// const String baseUrl = '$serverUrl/customers';
// const String consultationUrl =
//     "${wifiUrl}:8083/api/customer/getAllConsultations";
// const String registerUrl = '${wifiUrl}:8083/api/customers';
// const String categoryUrl = '${wifiUrl}:8081/admin/getCategories';
// const String getServiceByCategoriesID =
//     '${wifiUrl}:8081/admin/getServiceById';
// const String getSubServiceByServiceID =
//     '${wifiUrl}:8081/admin/getSubServicesByServiceId';
// const String getSubServiceByServiceIDHospitalID =
//     '${wifiUrl}:8080/clinic-admin/getSubService';
// const String getCustomer = '$baseUrl/getCustomer';
// const String BookingUrl = '${registerUrl}/bookService';

//local

// String serverUrl = 'alb-dev-sc-197990416.ap-south-1.elb.amazonaws.com/api';
// const String wifiUrl = "192.168.1.5";
// const String serverUrl = "${wifiUrl}:9090/api";
// const String clinicUrl = "${wifiUrl}:8080/clinic-admin";
// const String baseUrl = '$serverUrl/customers';
// const String consultationUrl =
//     "${wifiUrl}:8083/api/customer/getAllConsultations";
// const String registerUrl = '${wifiUrl}:8083/api/customer';
// const String categoryUrl = '${wifiUrl}:8081/admin/getCategories';
// // const String categoryUrl =
// //     '${wifiUrl}:8800/api/v1/category/getCategories';

// const String getServiceByCategoriesID =
//     '${wifiUrl}:8800/api/v1/services/getServices';

// const String getSubServiceByServiceID =
//     '${wifiUrl}:8081/admin/getSubServicesByServiceId';
// const String getSubServiceByServiceIDHospitalID =
//     '${wifiUrl}:8080/clinic-admin/getSubService';

// const String getCustomer =
//     '$baseUrl/getCustomer'; //localhost:8083/api/customer/getBasicDetails/${mobileNumber}
// // const String BookingUrl = '$wifiUrl:3000/bookings';
// const String BookingUrl = '${registerUrl}/bookService';
// // localhost:8083/api/customer/bookService
// // const String GetBookings = '$wifiUrl:3000/bookings?mobileNumber';
