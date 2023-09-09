
class Order {
  late final String id_order;
  late final int id_restaurant;
  late final String user_name;
  late final String username_pickup;
  late final String username_destination;
  late final String method_payment;
  late final String username_rider;
  late final String rider_plat;
  late final String rider_motor_type;
  late final String isOrder;
  late final double price_order;
  late final double food_price;
  late final String distance_order;
  late final String user_image_order;
  late final String date_order;
  late final String type_order;
  late final String restaurant_name;
  late final String review_driver;
  late final String detail_address;
  late final int rating_driver;
  late final List<String> foods_order;

  Order({
    required this.id_order,
    required this.id_restaurant,
    required this.user_name,
    required this.username_pickup,
    required this.username_destination,
    required this.method_payment,
    required this.username_rider,
    required this.rider_plat,
    required this.rider_motor_type,
    required this.isOrder,
    required this.price_order,
    required this.food_price,
    required this.distance_order,
    required this.user_image_order,
    required this.date_order,
    required this.type_order,
    required this.restaurant_name,
    required this.review_driver,
    required this.detail_address,
    required this.rating_driver,
    required this.foods_order,
  });
  // Order.fromJson(Map<String, Object> json)
  //     : this(
  //   id_order: json["id_order"] as String,
  //   id_restaurant: json["id_restaurant"] as String,
  //   user_name: json["user_name"] as String,
  // );

  Map<String, Object> toJson() {
    return {
      "id_order": id_order,
      "id_restaurant": id_restaurant,
      "user_name": user_name,
    };
  }

}
