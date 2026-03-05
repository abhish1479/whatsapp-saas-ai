import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/workflow_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workflow.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/ui/app_text_field.dart';

class WorkflowScreen extends ConsumerStatefulWidget {
  const WorkflowScreen({super.key});

  @override
  ConsumerState<WorkflowScreen> createState() =>
      _WorkflowScreenState();
}

class _WorkflowScreenState
    extends ConsumerState<WorkflowScreen> {

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workflowProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔹 HEADER (Like Templates)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Workflows",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Design conversation flows for your AI agent.",
                    style: TextStyle(
                        color:
                            AppColors.mutedForeground),
                  )
                ],
              ),
              AppButton(
                text: "Create Workflow",
                onPressed: () {
                  _showWorkflowDialog(
                      context, ref, null);
                },
              )
            ],
          ),
        ),

        /// 🔹 ERROR MESSAGE
        if (state.error != null)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.destructive
                  .withOpacity(0.1),
              child: Text(
                state.error!,
                style: const TextStyle(
                    color:
                        AppColors.destructive),
              ),
            ),
          ),

        /// 🔹 GRID LIST
        Expanded(
          child: state.isLoading &&
                  state.workflows.isEmpty
              ? const Center(
                  child:
                      CircularProgressIndicator())
              : state.workflows.isEmpty
                  ? const Center(
                      child: Text(
                        "No workflows found.",
                        style: TextStyle(
                            color: AppColors
                                .mutedForeground),
                      ),
                    )
                  : GridView.builder(
                      padding:
                          const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: 240,
                      ),
                      itemCount:
                          state.workflows.length,
                      itemBuilder:
                          (context, index) {
                        final workflow =
                            state.workflows[
                                index];

                        return _WorkflowCard(
                          key: ValueKey(workflow.id),
                          workflow: workflow,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  /// 🔥 DIALOG FORM
  void _showWorkflowDialog(
      BuildContext context,
      WidgetRef ref,
      Workflow? workflow) {

    final nameController =
        TextEditingController(
            text: workflow?.name ?? "");

    final workflowController =
        TextEditingController(
            text: workflow?.workflow ??
                "");

    bool isDefault =
        workflow?.isDefault ?? false;

    bool isGenerating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor:
                  AppColors.card,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          12)),
              title: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Text(
                    workflow == null
                        ? "Create Workflow"
                        : "Edit Workflow",
                    style: const TextStyle(
                        fontWeight:
                            FontWeight.w600),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close),
                    onPressed: () =>
                        Navigator.pop(
                            context),
                  )
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      /// NAME
                      AppTextField(
                        controller:
                            nameController,
                        labelText:
                            "Workflow Name",
                      ),
                      const SizedBox(
                          height: 16),

                      /// MAGIC BUTTON HEADER
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          const Text(
                            "Workflow Flow",
                            style: TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold),
                          ),
                          TextButton.icon(
                            onPressed: 
                            isGenerating
                                    ? null
                                    : () async {
                                        setState(() {
                                          isGenerating = true;
                                        });

                                        final result = await ref
                                            .read(workflowProvider.notifier)
                                            .optimizeWorkflow(
                                                workflowController.text);

                                        if (result != null) {
                                          setState(() {
                                            workflowController.text = result;
                                          });
                                        }

                                        setState(() {
                                          isGenerating = false;
                                        });
                                      },
                            icon:
                                const Icon(
                              Icons
                                  .auto_awesome,
                              color: AppColors
                                  .primary,
                            ),
                            label:
                                Text(
                              isGenerating
                                  ? "Generating..."
                                  : "Magic",
                              style:
                                  const TextStyle(
                                color:
                                    AppColors
                                        .primary,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(
                          height: 8),

                      /// WORKFLOW TEXTAREA
                      AppTextField(
                        controller:
                            workflowController,
                        maxLines: 8,
                        labelText:
                            "Workflow",
                      ),

                      const SizedBox(
                          height: 16),

                      /// DEFAULT SWITCH
                      Row(
                        children: [
                          Checkbox(
                              value:
                                  isDefault,
                              onChanged:
                                  (val) {
                                setState(() {
                                  isDefault =
                                      val ??
                                          false;
                                });
                              }),
                          const Text(
                              "Set as Default"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                AppButton(
                  text: "Save Workflow",
                  onPressed: () async {
                    await ref
                        .read(
                            workflowProvider
                                .notifier)
                        .saveWorkflow(
                          nameController
                              .text,
                          workflowController
                              .text,
                          isDefault,
                        );

                    Navigator.pop(
                        context);
                  },
                )
              ],
            );
          },
        );
      },
    );
  }
}

/// 🔹 WORKFLOW CARD
class _WorkflowCard
    extends ConsumerWidget {
  final Workflow workflow;

  const _WorkflowCard({
    super.key,
    required this.workflow,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref) {

    return AppCard(
      padding:
          const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          /// TOP ROW
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              const Icon(
                Icons.account_tree,
                color:
                    AppColors.primary,
              ),
              if (workflow.isDefault)
                AppBadge(
                  text: "Default",
                  variant:
                      AppBadgeVariant
                          .success,
                )
            ],
          ),

          const SizedBox(
              height: 12),

          /// NAME
          Text(
            workflow.name,
            style: const TextStyle(
                fontWeight:
                    FontWeight.w600),
          ),

          const SizedBox(
              height: 8),

          /// PREVIEW
          Expanded(
            child: Text(
              workflow.workflow,
              maxLines: 4,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color: AppColors
                    .mutedForeground,
              ),
            ),
          ),

          /// ACTIONS
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .end,
            children: [
              TextButton(
                onPressed: () {
                  ref
                      .read(
                          workflowProvider
                              .notifier)
                      .selectWorkflow(
                          workflow);
                  (context
                          .findAncestorStateOfType<
                              _WorkflowScreenState>())
                      ?._showWorkflowDialog(
                          context,
                          ref,
                          workflow);
                },
                child:
                    const Text("Edit"),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(
                          workflowProvider
                              .notifier)
                      .deleteWorkflow(
                          workflow.id);
                },
                child:
                    const Text(
                  "Delete",
                  style: TextStyle(
                      color:
                          Colors.red),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}