import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'premium_bottom_sheet.dart';

class MobileTopBar extends StatelessWidget {
  final String? title;
  
  const MobileTopBar({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu button
        GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8ECEF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu, color: Color(0xFF2C3333), size: 20),
          ),
        ),
        
        // Greeting or Title
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: title != null
                ? Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF2C3333)
                    ),
                  )
                : Row(
                    children: const [
                      Text(
                        "Hi, ",
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold, 
                          fontStyle: FontStyle.italic, 
                          color: Color(0xFF2C3333)
                        ),
                      ),
                      Text(
                        "Alex",
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold, 
                          fontStyle: FontStyle.italic, 
                          color: Color(0xFF2988FA)
                        ),
                      ),
                      SizedBox(width: 4),
                      Text("👋", style: TextStyle(fontSize: 20)),
                    ],
                  ),
          ),
        ),

        // Pro Badge
        GestureDetector(
          onTap: () => showPremiumBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.workspace_premium, color: Color(0xFFF6A723), size: 16),
                SizedBox(width: 4),
                Text("Pro", style: TextStyle(color: Color(0xFF2C3333), fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 12),

        // Notification Bell
        GestureDetector(
          onTap: () => context.push('/notifications'),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8ECEF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Color(0xFF2C3333), size: 20),
          ),
        ),
      ],
    );
  }
}
