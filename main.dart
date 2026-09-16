import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 1. DOMAIN LAYER: Order Entity ---
class OrderEntity {
final String id;
final String customerName;
final String customerPhone;
final String storeName;
final String orderDetails;
final double estimatedPrice;
final String status; // 'جديد', 'قيد الشراء', 'في الطريق', 'تم التوصيل'
final DateTime createdAt;

OrderEntity({
required this.id,
required this.customerName,
required this.customerPhone,
required this.storeName,
required this.orderDetails,
required this.estimatedPrice,
required this.status,
required this.createdAt,
});
}

// --- 2. PRESENTATION LAYER: Riverpod State Management ---
class OrdersNotifier extends AsyncNotifier<List<OrderEntity>> {
@override
Future<List<OrderEntity>> build() async {
return [
OrderEntity(
id: '1',
customerName: 'سعيد القحطاني',
customerPhone: '0501234567',
storeName: 'سوبرماركت التميمي',
orderDetails: 'حليب طازج، خبز، قهوة عربية',
estimatedPrice: 75.0,
status: 'جديد',
createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
),
OrderEntity(
id: '2',
customerName: 'فهد الدوسري',
customerPhone: '0559876543',
storeName: 'صيدلية النهدي',
orderDetails: 'فيتامينات، مسكن ألم',
estimatedPrice: 120.0,
status: 'قيد الشراء',
createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
),
 ];
}

Future<void> addOrder(OrderEntity newOrder) async {
state = const AsyncValue.loading();
state = await AsyncValue.guard(() async {
final currentOrders = state.value ?? [];
return [newOrder, ...currentOrders];
});
}

Future<void> updateOrderStatus(String orderId, String newStatus) async {
state = const AsyncValue.loading();
state = await AsyncValue.guard(() async {
final currentOrders = state.value ?? [];
return currentOrders.map((order) {
if (order.id == orderId) {
return OrderEntity(
id: order.id,
customerName: order.customerName,
customerPhone: order.customerPhone,
storeName: order.storeName,
orderDetails: order.orderDetails,
estimatedPrice: order.estimatedPrice,
status: newStatus,
createdAt: order.createdAt,
);
}
return order;
}).toList();
});
}
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<OrderEntity>>(
() => OrdersNotifier(),
);

// --- 3. APPLICATION ENTRY POINT ---
void main() {
runApp(
const ProviderScope(
child: PersonalDeliveryApp(),
),
);
}

class PersonalDeliveryApp extends StatelessWidget {
const PersonalDeliveryApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'توصيل طلباتي الشخصية',
debugShowCheckedModeBanner: false,
theme: ThemeData(
colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
useMaterial3: true,
),
builder: (context, child) {
return Directionality(
textDirection: TextDirection.rtl,
child: child!,
);
},
home: const MainNavigationScreen(),
);
}
}

// --- 4. NAVIGATION CONTAINER ---
class MainNavigationScreen extends StatefulWidget {
const MainNavigationScreen({super.key});

@override
State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
int _currentIndex = 0;

final List<Widget> _screens = [
const OrdersScreen(),
const AddCustomerOrderScreen(),
const StatsScreen(),
 ];

@override
Widget build(BuildContext context) {
final screenWidth = MediaQuery.of(context).size.width;
final isDesktopOrTablet = screenWidth > 600;

return Scaffold(
body: Center(
child: ConstrainedBox(
constraints: BoxConstraints(
maxWidth: isDesktopOrTablet ? 650 : double.infinity,
),
child: _screens[_currentIndex],
),
),
bottomNavigationBar: NavigationBar(
selectedIndex: _currentIndex,
onDestinationSelected: (index) {
setState(() {
_currentIndex = index;
});
},
destinations: const [
NavigationDestination(
icon: Icon(Icons.list_alt),
label: 'الطلبات',
),
NavigationDestination(
icon: Icon(Icons.add_shopping_cart),
label: 'طلب جديد (زبون)',
),
NavigationDestination(
icon: Icon(Icons.analytics),
label: 'الإحصائيات',
),
 ],
),
);
}
}

// --- 5. SCREEN 1: Orders List Screen ---
class OrdersScreen extends ConsumerWidget {
const OrdersScreen({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
final ordersAsync = ref.watch(ordersProvider);

return Scaffold(
appBar: AppBar(
title: const Text('إدارة طلبات التوصيل (سيارتي)'),
centerTitle: true,
),
body: ordersAsync.when(
data: (orders) {
if (orders.isEmpty) {
return const Center(child: Text('لا توجد طلبات حالياً'));
}
return ListView.builder(
itemCount: orders.length,
padding: const EdgeInsets.all(16),
itemBuilder: (context, index) {
final order = orders[index];
return Card(
elevation: 2,
margin: const EdgeInsets.only(bottom: 12),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
child: InkWell(
borderRadius: BorderRadius.circular(12),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => OrderDetailsScreen(orderId: order.id),
),
);
},
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
order.customerName,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
Chip(
label: Text(
order.status,
style: const TextStyle(color: Colors.white, fontSize: 12),
),
backgroundColor: _getStatusColor(order.status),
),
 ],
),
const SizedBox(height: 6),
Text('المتجر: {order.orderDetails}', maxLines: 1, overflow: TextOverflow.ellipsis),
const SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('القيمة التقديرية: latex
{order.estimatedPrice} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), ], ), ], ), ), ), ); }, ); }, loading: () =&gt; const Center(child: CircularProgressIndicator()), error: (err, stack) =&gt; Center(child: Text('حدث خطأ: 

err')),
),
);
}

Color _getStatusColor(String status) {
switch (status) {
case 'جديد':
return Colors.orange;
case 'قيد الشراء':
return Colors.blue;
case 'في الطريق':
return Colors.purple;
case 'تم التوصيل':
return Colors.green;
default:
return Colors.grey;
}
}
}

// --- 6. SCREEN 2: Order Details & Actions Screen ---
class OrderDetailsScreen extends ConsumerWidget {
final String orderId;

const OrderDetailsScreen({super.key, required this.orderId});

@override
Widget build(BuildContext context, WidgetRef ref) {
final orders = ref.watch(ordersProvider).value ?? [];
final order = orders.firstWhere((o) => o.id == orderId, orElse: () => orders.first);

return Scaffold(
appBar: AppBar(
title: Text('تفاصيل الطلب #{order.customerPhone}', style: const TextStyle(fontSize: 16)),
const Divider(height: 25),
Text('تفاصيل الشراء', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
const SizedBox(height: 5),
Text('المتجر: {order.orderDetails}', style: const TextStyle(fontSize: 16)),
const SizedBox(height: 10),
Text('السعر التقديري: $`{order.estimatedPrice} ر.س', style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
],
),
),
),
const SizedBox(height: 25),
const Text('تحديث حالة الطلب السريعة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
const SizedBox(height: 10),
Wrap(
spacing: 10,
children: ['جديد', 'قيد الشراء', 'في الطريق', 'تم التوصيل'].map((status) {
final isSelected = order.status == status;
return ChoiceChip(
label: Text(status),
selected: isSelected,
onSelected: (selected) {
ref.read(ordersProvider.notifier).updateOrderStatus(order.id, status);
},
);
}).toList(),
),
const SizedBox(height: 35),
SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
style: ElevatedButton.styleFrom(
padding: const EdgeInsets.symmetric(vertical: 14),
backgroundColor: Colors.deepOrange,
foregroundColor: Colors.white,
),
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('تم الاتصال بالزبون بنجاح')),
);
},
icon: const Icon(Icons.phone),
label: const Text('اتصال بالزبون', style: TextStyle(fontSize: 16)),
),
),
const SizedBox(height: 20),
],
),
),
);
}
}

// --- 7. SCREEN 3: Simulate Customer Adding Order ---
class AddCustomerOrderScreen extends ConsumerStatefulWidget {
const AddCustomerOrderScreen({super.key});

@override
ConsumerState<AddCustomerOrderScreen> createState() => _AddCustomerOrderScreenState();
}

class _AddCustomerOrderScreenState extends ConsumerState<AddCustomerOrderScreen> {
final _nameController = TextEditingController();
final _phoneController = TextEditingController();
final _storeController = TextEditingController();
final _detailsController = TextEditingController();
final _priceController = TextEditingController();

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('محاكاة طلب جديد من زبون')),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'اسم الزبون', border: OutlineInputBorder())),
const SizedBox(height: 12),
TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'رقم الجوال', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
const SizedBox(height: 12),
TextField(controller: _storeController, decoration: const InputDecoration(labelText: 'المتجر المطلوب', border: OutlineInputBorder())),
const SizedBox(height: 12),
TextField(controller: _detailsController, decoration: const InputDecoration(labelText: 'تفاصيل الأغراض المطلوبة', border: OutlineInputBorder()), maxLines: 3),
const SizedBox(height: 12),
TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'السعر التقديري (ر.س)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
const SizedBox(height: 20),
SizedBox(
width: double.infinity,
child: FilledButton(
onPressed: () {
if (_nameController.text.isEmpty || _storeController.text.isEmpty) return;

final newOrder = OrderEntity(
id: DateTime.now().millisecondsSinceEpoch.toString().substring(8),
customerName: _nameController.text,
customerPhone: _phoneController.text.isEmpty ? '0500000000' : _phoneController.text,
storeName: _storeController.text,
orderDetails: _detailsController.text,
estimatedPrice: double.tryParse(_priceController.text) ?? 50.0,
status: 'جديد',
createdAt: DateTime.now(),
);

ref.read(ordersProvider.notifier).addOrder(newOrder);

_nameController.clear();
_phoneController.clear();
_storeController.clear();
_detailsController.clear();
_priceController.clear();

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('تم إرسال الطلب بنجاح إلى جدول السائق!')),
);
},
child: const Text('إرسال الطلب الآن', style: TextStyle(fontSize: 16)),
),
),
],
),
),
);
}
}

// --- 8. SCREEN 4: Stats Screen ---
class StatsScreen extends ConsumerWidget {
const StatsScreen({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
final orders = ref.watch(ordersProvider).value ?? [];
final totalOrders = orders.length;
final completedOrders = orders.where((o) => o.status == 'تم التوصيل').length;
final pendingOrders = totalOrders - completedOrders;

return Scaffold(
appBar: AppBar(title: const Text('إحصائيات التوصيل')),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
Row(
children: [
Expanded(child: _buildStatCard('إجمالي الطلبات', '$totalOrders', Colors.blue)), const SizedBox(width: 12), Expanded(child: _buildStatCard('المنجزة', '$completedOrders', Colors.green)),
 ],
),
const SizedBox(height: 12),
Row(
children: [
Expanded(child: _buildStatCard('قيد العمل', '`$pendingOrders', Colors.orange)),
const SizedBox(width: 12),
Expanded(child: _buildStatCard('التقييم العام', '4.9 ⭐', Colors.purple)),
 ],
),
],
),
),
);
}

Widget _buildStatCard(String title, String value, Color color) {
return Card(
elevation: 3,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: Padding(
padding: const EdgeInsets.all(20.0),
child: Column(
children: [
Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
const SizedBox(height: 10),
Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
],
),
),
);
}
}