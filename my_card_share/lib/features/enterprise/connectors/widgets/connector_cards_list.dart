import 'package:flutter/material.dart';

class ConnectorCardsList extends StatefulWidget {
  final Function(String crmName)? onConnectTap;

  const ConnectorCardsList({
    super.key,
    this.onConnectTap,
  });

  @override
  State<ConnectorCardsList> createState() => _ConnectorCardsListState();
}

class _ConnectorCardsListState extends State<ConnectorCardsList> {
  final Map<String, bool> _connectionStates = {
    "Salesforce": true,
    "HubSpot": true,
    "Zapier": false,
    "Follow Up Boss": false,
  };

  @override
  Widget build(BuildContext context) {
    final crms = [
      {
        "name": "Salesforce",
        "icon": Icons.cloud_done_rounded,
        "iconColor": const Color(0xFF0284C7),
        "iconBg": const Color(0xFFE0F2FE),
        "instance": "Instance: acme.my.salesforce.com",
      },
      {
        "name": "HubSpot",
        "icon": Icons.hub_rounded,
        "iconColor": const Color(0xFFEA580C),
        "iconBg": const Color(0xFFFFEDD5),
        "instance": null,
      },
      {
        "name": "Zapier",
        "icon": Icons.bolt_rounded,
        "iconColor": const Color(0xFFD97706),
        "iconBg": const Color(0xFFFEF3C7),
        "instance": null,
      },
      {
        "name": "Follow Up Boss",
        "icon": Icons.badge_outlined,
        "iconColor": const Color(0xFF0D9488),
        "iconBg": const Color(0xFFCCFBF1),
        "instance": null,
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: crms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final crm = crms[index];
        final name = crm["name"] as String;
        final isConnected = _connectionStates[name] ?? false;
        final instance = crm["instance"] as String?;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Square Icon Logo Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: crm["iconBg"] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  crm["icon"] as IconData,
                  color: crm["iconColor"] as Color,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Center Info: CRM Name, Status & Instance Caption
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isConnected
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isConnected ? "Connected" : "Not Connected",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isConnected
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    if (instance != null && isConnected) ...[
                      const SizedBox(height: 3),
                      Text(
                        instance,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right Action: Toggle Switch or Outlined "Connect" Button
              if (isConnected)
                Switch(
                  value: true,
                  activeThumbColor: const Color(0xFF0052FF),
                  activeTrackColor: const Color(0xFFDBEAFE),
                  onChanged: (val) {
                    setState(() {
                      _connectionStates[name] = val;
                    });
                  },
                )
              else
                OutlinedButton(
                  onPressed: () {
                    if (widget.onConnectTap != null) {
                      widget.onConnectTap!(name);
                    }
                    setState(() {
                      _connectionStates[name] = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0052FF),
                    side: const BorderSide(color: Color(0xFF0052FF), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Connect",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
