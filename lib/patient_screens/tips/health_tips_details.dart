import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as gpt;
import 'package:flutter_html/flutter_html.dart';

class HealthTipDetailPage extends StatefulWidget {
  final String category;
  final String image;
  HealthTipDetailPage({required this.category, required this.image});

  @override
  _HealthTipDetailPageState createState() => _HealthTipDetailPageState();
}

class _HealthTipDetailPageState extends State<HealthTipDetailPage> {
  static const apiKey = 'AIzaSyDlZMRly2BTsUK1c4OhfTBrKKrw15UREL0';
  final model = gpt.GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  late Future<String> healthTip;

  @override
  void initState() {
    super.initState();
    healthTip = fetchHealthTip(widget.category);
  }

  Future<String> fetchHealthTip(String category) async {
    final response = await model.generateContent([
      gpt.Content.text(
          'Provide a useful health tip about $category. You can add examples and other info about it.')
    ]);
    return response.text ?? 'No data available';
  }

  String formatHealthTip(String text) {
    // Handle bullet points with bold subtopics and make the bold text all caps
    text = text.replaceAllMapped(RegExp(r'\* \*\*(.*?)\*\*'),
        (match) => '<br><br><b>${match[1]}</b><br>');

    // Add a line break before every bold item, format bullets properly, and make bold text all caps
    text = text.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'),
        (match) => '<br><br><b>${match[1]!.toUpperCase()}</b><br>');
    text = text.replaceAllMapped(
        RegExp(r'\*(.*?)\n'), (match) => '<ul><li>${match[1]}</li></ul><br>');

    text = text.replaceAllMapped(RegExp(r'([^\*]*?)(\*\*|\* )'), (match) {
      return '${match[1]}<br>${match[2]}';
    });
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Color(0xFF3E4D99),
            foregroundColor: Colors.white,
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.category,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.image,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(CupertinoIcons.back),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FutureBuilder<String>(
                      future: healthTip,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: SpinKitThreeBounce(
                              size: 20,
                              color: Color(0xFF343F9B),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final formattedText =
                              formatHealthTip(snapshot.data ?? 'No data');
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Html(
                              data: formattedText,
                              style: {
                                "b": Style(
                                  fontWeight: FontWeight.w600,
                                  fontSize: FontSize(15),
                                  color: Color(0xFF3E4D99),
                                ),
                                "ul": Style(
                                  padding: HtmlPaddings.symmetric(vertical: 2),
                                  //listStylePosition: ListStylePosition.INSIDE,
                                  margin: Margins.symmetric(vertical: 5),
                                ),
                                "li": Style(
                                  fontSize: FontSize(15),
                                  padding: HtmlPaddings.zero,
                                ),
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
