import 'package:flutter/material.dart';
import '../../auth/back/smart_back_handler.dart';
import '../../auth/font style/font_style.dart';
import 'widgets/workspace_header_section.dart';
import 'widgets/workspace_list_section.dart';
import 'widgets/map_custom_domain_card.dart';

class PlatformWorkspacesScreen extends StatefulWidget {
  const PlatformWorkspacesScreen({super.key});

  @override
  State<PlatformWorkspacesScreen> createState() => _PlatformWorkspacesScreenState();
}

class _PlatformWorkspacesScreenState extends State<PlatformWorkspacesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Real-time search filtering logic
    final filteredWorkspaces = WorkspaceListSection.defaultWorkspaces.where((item) {
      if (_searchQuery.trim().isEmpty) return true;
      final query = _searchQuery.toLowerCase().trim();
      final statusStr = item.isActive ? "active" : "unassigned";
      return item.domain.toLowerCase().contains(query) ||
          item.companyName.toLowerCase().contains(query) ||
          statusStr.contains(query);
    }).toList();

    return SmartPopScope(
      onBack: () => SmartBackHandler.handleMasterAdminBack(context: context),
      child: Stack(
        children: [
          // Soft baby-blue gradient blob top-right corner
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDBEAFE).withValues(alpha: 0.7),
                    const Color(0xFFEFF6FF).withValues(alpha: 0.2),
                    const Color(0xFFF8FAFD).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

        // Main scrollable content
        DefaultTextStyle(
          style: AppFontStyle.bodyMedium,
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtext & Search Bar Header
              WorkspaceHeaderSection(
                onSearchChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Real-time filtered Workspace Rows List
              WorkspaceListSection(
                workspaces: filteredWorkspaces,
                onWorkspaceTap: (item) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Selected workspace: ${item.domain}"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onMenuTap: (item) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Options for ${item.companyName}"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Map New Custom Domain Dashed Card
              MapCustomDomainCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Map New Custom Domain tapped"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        ),
      ],
    ),
    );
  }
}
