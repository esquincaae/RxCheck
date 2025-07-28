import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── DATASOURCES ──────────────────────────────────────────────────────────────
import 'infrastructure/datasource/http_auth_datasource.dart';
import 'infrastructure/datasource/http_recipe_datasource.dart';
import 'infrastructure/datasource/http_user_datasource.dart';

// ─── REPOSITORIES ────────────────────────────────────────────────────────────
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'infrastructure/repositories/recipe_repository_impl.dart';
import 'infrastructure/repositories/user_repository_impl.dart';

// ─── USE CASES ────────────────────────────────────────────────────────────────
import 'application/usecases/login_usecase.dart';
import 'application/usecases/signup_usecase.dart';
import 'application/usecases/fetch_recipes_usecase.dart';
import 'application/usecases/fetch_medications_usecase.dart';
import 'application/usecases/fetch_qr_usecase.dart';
import 'application/usecases/supply_medications_usecase.dart';
import 'application/usecases/get_user_usecase.dart';
import 'application/usecases/update_profile_usecase.dart';
import 'application/usecases/update_image_usecase.dart';
import 'application/usecases/request_password_reset_usecase.dart';
import 'application/usecases/confirm_password_reset_usecase.dart';

// ─── VIEWMODELS ───────────────────────────────────────────────────────────────
import 'presentation/viewmodels/login_viewmodel.dart';
import 'presentation/viewmodels/signup_viewmodel.dart';
import 'presentation/viewmodels/recipe_list_viewmodel.dart';
import 'presentation/viewmodels/recipe_detail_viewmodel.dart';
import 'presentation/viewmodels/edit_profile_viewmodel.dart';
import 'presentation/viewmodels/reset_password_viewmodel.dart';
import 'presentation/viewmodels/confirm_password_viewmodel.dart';

// ─── SCREENS ─────────────────────────────────────────────────────────────────
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/reset_password_screen.dart';
import 'presentation/screens/confirm_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final prefs   = await SharedPreferences.getInstance();
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['API_URL']!;

  // Instanciamos datasources
  final authDs   = HttpAuthDataSource('$baseUrl/user');
  final recipeDs = HttpRecipeDataSource(baseUrl);
  final userDs   = HttpUserDataSource('$baseUrl/user');

  // Instanciamos repositorios
  final authRepo   = AuthRepositoryImpl(authDs, storage, prefs);
  final recipeRepo = RecipeRepositoryImpl(recipeDs, storage);
  final userRepo   = UserRepositoryImpl(userDs, storage, prefs);

  // Instanciamos use cases
  final loginUc         = LoginUseCase(authRepo);
  final signupUc        = SignupUseCase(authRepo);
  final fetchRecipesUc  = FetchRecipesUseCase(recipeRepo);
  final fetchMedsUc     = FetchMedicationsUseCase(recipeRepo);
  final fetchQrUc       = FetchQrUseCase(recipeRepo);
  final supplyMedsUc    = SupplyMedicationsUseCase(recipeRepo);
  final getUserUc       = GetUserUseCase(userRepo);
  final updateProfileUc = UpdateProfileUseCase(userRepo);
  final updateImageUc   = UpdateImageUseCase(userRepo);
  final requestResetUc  = RequestPasswordResetUseCase(authRepo);
  final confirmResetUc  = ConfirmPasswordResetUseCase(authRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(loginUc)),
        ChangeNotifierProvider(create: (_) => SignupViewModel(signupUc)),
        ChangeNotifierProvider(create: (_) => RecipeListViewModel(fetchRecipesUc)),
        ChangeNotifierProvider(
          create: (_) => RecipeDetailViewModel(fetchMedsUc, fetchQrUc, supplyMedsUc),
        ),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel(getUserUc, updateProfileUc, updateImageUc)),
        ChangeNotifierProvider(create: (_) => ResetPasswordViewModel(requestResetUc)),
        ChangeNotifierProvider(create: (_) => ConfirmPasswordViewModel(confirmResetUc)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RxCheck',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
        routes: {
          '/reset': (_) => ResetPasswordScreen(),
          '/confirm': (_) => ConfirmPasswordScreen(),
        },
      ),
    ),
  );
}
