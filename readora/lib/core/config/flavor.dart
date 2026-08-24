/// Build flavors. `dev` and `prod` install side by side on one device
/// (the dev Android applicationId gets a `.dev` suffix) and point at
/// separate Supabase projects, so testing a migration can never touch
/// real user data.
enum Flavor {
  dev,
  prod;

  static Flavor fromName(String name) => switch (name) {
        'prod' => Flavor.prod,
        _ => Flavor.dev,
      };

  bool get isDev => this == Flavor.dev;
  bool get isProd => this == Flavor.prod;
}
