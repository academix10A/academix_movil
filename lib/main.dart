import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'core/network/dio_client.dart';
import 'features/auth/presentation/view/login_screen.dart';
import 'core/routes/app_routes.dart';
import 'features/home/presentation/view/main_screen.dart';
import 'features/library/presentation/view/book_detail_screen.dart';
import 'features/note/presentation/view/note_detail_screen.dart';
import 'features/note/presentation/view/create_note_screen.dart';
import 'features/exam/presentation/view/exam_take_screen.dart';
import 'features/exam/presentation/view/exam_result_screen.dart';
import 'features/profile/presentation/view/settings_screen.dart';
import 'features/profile/presentation/view/premium_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/library/presentation/viewmodel/library_viewmodel.dart';
import 'features/note/presentation/viewmodel/notes_viewmodel.dart';
import 'features/exam/presentation/viewmodel/exams_viewmodel.dart';
import 'features/auth/presentation/view/register_screen.dart';
import 'features/auth/presentation/view/forgot_password_screen.dart';
import 'features/auth/presentation/view/splash_screen.dart';
import 'features/profile/presentation/view/favorites_screen.dart';
import 'features/home/presentation/view/offline_content_screen.dart';
import 'features/library/presentation/view/search_screen.dart';
import 'features/library/presentation/view/ai_chat_screen.dart';
import 'features/exam/presentation/view/exam_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  DioClient.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.main:
            return MaterialPageRoute(builder: (_) => const MainScreen());
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.search:
            return MaterialPageRoute(builder: (_) => const SearchScreen());
          case AppRoutes.favorites:
            return MaterialPageRoute(builder: (_) => const FavoritesScreen());
          case AppRoutes.offline:
            return MaterialPageRoute(builder: (_) => const OfflineContentScreen());
          case AppRoutes.bookDetail:
            final resource = settings.arguments as LibraryResource;
            return MaterialPageRoute(
              builder: (_) => BookDetailScreen(resource: resource),
            );
          case AppRoutes.noteDetail:
            final note = settings.arguments as NoteItem;
            return MaterialPageRoute(
              builder: (_) => NoteDetailScreen(note: note),
            );
          case AppRoutes.createNote:
            return MaterialPageRoute(builder: (_) => const CreateNoteScreen());
          case AppRoutes.examTake:
            final exam = settings.arguments as ExamItem;
            return MaterialPageRoute(
              builder: (_) => ExamTakeScreen(exam: exam),
            );
          case AppRoutes.examResult:
            final args = settings.arguments as Map<String, dynamic>;
            final exam = args["exam"] as ExamItem?;
            final completedExam = args["completedExam"] as CompletedExamItem?;
            return MaterialPageRoute(
              builder: (_) => ExamResultScreen(
                exam: exam,
                completedExam: completedExam,
                score: args["score"] as int,
                grade: args["grade"] as String,
                correctAnswers: args["correctAnswers"] as int,
                totalQuestions: args["totalQuestions"] as int,
              ),
            );
          case AppRoutes.settings:
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case AppRoutes.premium:
            return MaterialPageRoute(builder: (_) => const PremiumScreen());
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case AppRoutes.forgotPassword:
            return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
          case AppRoutes.aiChat:
            return MaterialPageRoute(builder: (_) => const AiChatScreen());
          case AppRoutes.examHistory:
            return MaterialPageRoute(builder: (_) => const ExamHistoryScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}

