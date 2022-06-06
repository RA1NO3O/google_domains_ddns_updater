import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum IPSourceType {
  unspecified,
  specified,
  customService;

  static const List<String> _ipSourceTypes = ['不指定', '指定IP', '自定公网IP查询服务'];

  String get text {
    switch (this) {
      case unspecified:
        return _ipSourceTypes[0];
      case specified:
        return _ipSourceTypes[1];
      case customService:
        return _ipSourceTypes[2];
      default:
        throw ('Unsupported IPSource Type.');
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Domains DDNS Updater',
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final SharedPreferences pref;
  String result = '';
  bool _isProcessing = false;
  bool _saveInfo = false;
  bool _expandExtraSettings = false;
  final _usernameField = TextEditingController();
  final _passwordField = TextEditingController();
  final _hostnameField = TextEditingController();
  final _specifiedIPField = TextEditingController();
  final _customIFConfigDomainField = TextEditingController();

  IPSourceType _ipSourceType = IPSourceType.unspecified;

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      pref = value;
      _saveInfo = pref.getBool('save_info') ?? false;
      _usernameField.text = pref.getString('saved_username') ?? '';
      _passwordField.text = pref.getString('saved_password') ?? '';
      _hostnameField.text = pref.getString('saved_hostname') ?? '';
      _customIFConfigDomainField.text =
          pref.getString('saved_customIFConfigDomain') ?? '';
      _specifiedIPField.text = pref.getString('saved_specifiedIP') ?? '';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Google域名 - DDNS更新器')),
        body: Flex(
          direction: Axis.vertical,
          children: [
            Visibility(
                visible: _isProcessing, child: const LinearProgressIndicator()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    enabled: !_isProcessing,
                    controller: _usernameField,
                    decoration: const InputDecoration(labelText: '用户名*'),
                  ),
                  TextField(
                    enabled: !_isProcessing,
                    controller: _passwordField,
                    decoration: const InputDecoration(labelText: '密码*'),
                  ),
                  TextField(
                    enabled: !_isProcessing,
                    controller: _hostnameField,
                    decoration: const InputDecoration(labelText: '主机名称*'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                          value: _saveInfo,
                          onChanged: _isProcessing
                              ? null
                              : (_) => setState(() => _saveInfo = !_saveInfo)),
                      const Text('保存信息'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _updateClick(),
                    icon: const Icon(Icons.update),
                    label: const Text('更新'),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    height: _expandExtraSettings ? 160 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    child: _expandExtraSettings
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text('IP源: '),
                                    DropdownButton(
                                        value: _ipSourceType,
                                        items: IPSourceType.values
                                            .map((e) =>
                                                DropdownMenuItem<IPSourceType>(
                                                    value: e,
                                                    child: Text(e.text)))
                                            .toList(),
                                        onChanged: (IPSourceType? v) => v !=
                                                null
                                            ? setState(() => _ipSourceType = v)
                                            : null),
                                  ],
                                ),
                                _ipSourceType == IPSourceType.specified
                                    ? TextField(
                                        enabled: !_isProcessing,
                                        controller: _specifiedIPField,
                                        decoration: const InputDecoration(
                                            labelText: 'IPV4地址',
                                            hintText: '1.2.3.4'))
                                    : _ipSourceType ==
                                            IPSourceType.customService
                                        ? TextField(
                                            enabled: !_isProcessing,
                                            controller:
                                                _customIFConfigDomainField,
                                            decoration: const InputDecoration(
                                                labelText: '公网IP查询服务URL',
                                                hintText: 'http:// 或 https://'),
                                          )
                                        : const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('不指定时，使用发送请求的代理的 IP。'),
                                          ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                    style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red),
                                        overlayColor: MaterialStateProperty.all(
                                            Colors.red.withAlpha(32))),
                                    onPressed: () => pref.clear(),
                                    icon: const Icon(Icons.clear),
                                    label: const Text('清除保存信息'))
                              ],
                            ),
                          )
                        : null,
                  ),
                  TextButton.icon(
                      onPressed: () => setState(
                          () => _expandExtraSettings = !_expandExtraSettings),
                      icon: Icon(_expandExtraSettings
                          ? Icons.expand_less
                          : Icons.expand_more),
                      label: Text('${_expandExtraSettings ? '隐藏' : '显示'}高级选项')),
                  const SizedBox(height: 8),
                  Text(result),
                ],
              ),
            ),
          ],
        ),
      );

  void _updateClick() {
    setState(() => _isProcessing = true);
    if (_ipSourceType == IPSourceType.customService) {
      Dio().get(_customIFConfigDomainField.text).then((value) {
        debugPrint('当前IP地址:$value');
        _updateDDNS(value.toString().replaceAll('\n', ''))
            .then((res) => setState(() {
                  result = res.toString();
                  _isProcessing = false;
                }));
      }).catchError((e) {
        debugPrint(e.toString());
        setState(() => _isProcessing = false);
      });
    } else {
      _updateDDNS(_specifiedIPField.text)
          .then((res) => setState(() {
                result = res.toString();
                _isProcessing = false;
              }))
          .catchError((e) {
        debugPrint(e.toString());
        setState(() => _isProcessing = false);
      });
    }
  }

  Future<Response> _updateDDNS(String ipAddress) async => Dio().get(
      'https://${_usernameField.text}:${_passwordField.text}'
      '@domains.google.com/nic/update'
      '?hostname=${_hostnameField.text}'
      '${_ipSourceType == IPSourceType.unspecified ? '' : '&myip=$ipAddress'}');

  @override
  void dispose() {
    if (_saveInfo) {
      pref.setString('saved_username', _usernameField.text);
      pref.setString('saved_password', _passwordField.text);
      pref.setString('saved_hostname', _hostnameField.text);
      pref.setString(
          'saved_customIFConfigDomain', _customIFConfigDomainField.text);
      pref.setString('saved_specifiedIP', _specifiedIPField.text);
    }
    super.dispose();
  }
}
