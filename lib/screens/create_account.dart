import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart' hide Provider;
import 'package:climit/providers/wallet_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ADD dependencies
import 'dart:developer';
import 'dart:collection';
import 'dart:io';

import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';


class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController controller = TextEditingController();
  FToast? fToast;
  final String clientId = dotenv.get('CLIENT_ID');

  @override
  void initState() {
    super.initState();
    initPlatformState(clientId);
    fToast = FToast();
    fToast?.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<WalletProvider>(
          builder: (context, value, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 51, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 50),
                  24.verticalSpace,
                  Container(
                    margin: const EdgeInsets.only(left: 30),
                    child: TextButton.icon(
                        onPressed: () async {
                          try {
                            Web3AuthResponse res = await _login(_withGoogle);
                            await context.read<WalletProvider>().createSmartWallet(res);                      
                            Navigator.pushNamed(context, '/home');
                          } catch (e) {
                            'Something went wrong: $e';
                          }
                        },
                        icon: const Icon(Icons.key),
                        label: const Text('Create Smart Account')),
                  ),
                
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> initPlatformState(String clientId) async {
    HashMap themeMap = HashMap<String, String>();
    themeMap['primary'] = "#229954";

    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = Uri.parse(
          'climit://io.climit.examplewallet/auth');
    } else if (Platform.isIOS) {
      redirectUrl =
          Uri.parse('io.climit.examplewallet://openlogin');
    } else {
      throw UnKnownException('Unknown platform');
    }

    final loginConfig = HashMap<String, LoginConfigItem>();
    loginConfig['jwt'] = LoginConfigItem(
        verifier: "w3a-auth0-demo", // get it from web3auth dashboard
        typeOfLogin: TypeOfLogin.jwt,
        clientId: "hUVVf4SEsZT7syOiL0gLU9hFEtm2gQ6O" // auth0 client id
        );

    await Web3AuthFlutter.init(
      Web3AuthOptions(
        clientId:
            clientId,
        //sdkUrl: 'https://auth.mocaverse.xyz',
        //walletSdkUrl: 'https://lrc-mocaverse.web3auth.io',
        network: Network.sapphire_devnet,
        buildEnv: BuildEnv.testing,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(
          mode: ThemeModes.dark,
          defaultLanguage: Language.en,
          appName: "Web3Auth Flutter App",
          theme: themeMap,
        ),
        loginConfig: loginConfig,
      ),
    );

    await Web3AuthFlutter.initialize();

    final String res = await Web3AuthFlutter.getPrivKey();
    log(res);
    if (res.isNotEmpty) {
      setState(() {
      });
    }
  }
  Future<Web3AuthResponse> _login(Future<Web3AuthResponse> Function() method ) async {
    Web3AuthResponse res = Web3AuthResponse();
    try {
      res = await method();
      setState(() {
      });
    } on UserCancelledException {
      log("User cancelled.");
    } on UnKnownException {
      log("Unknown exception occurred");
    } catch (e) {
      log(e.toString());
    }
    return res;
  }
  Future<Web3AuthResponse> _withGoogle() {
    return Web3AuthFlutter.login(
      LoginParams(loginProvider: Provider.google, mfaLevel: MFALevel.NONE),
    );
  }

}

