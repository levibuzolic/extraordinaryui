defmodule CinderUI.InstallTaskTest do
  use ExUnit.Case, async: false

  @task "cinder_ui.install"

  setup do
    tmp_dir =
      Path.join(
        System.tmp_dir!(),
        "cinder-ui-install-test-#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(tmp_dir)

    on_exit(fn ->
      File.rm_rf!(tmp_dir)
    end)

    %{tmp_dir: tmp_dir}
  end

  test "installs into project root package manager when root package.json exists", %{
    tmp_dir: tmp_dir
  } do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(Path.join(project, "package.json"), "{\n  \"private\": true\n}\n")
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")

    write_fake_npm!(bin_dir)

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "npm"])
      end)
    end)

    assert File.exists?(Path.join(assets, "css/cinder_ui.css"))
    assert File.exists?(Path.join(assets, "js/cinder_ui.js"))
    npm_args = File.read!(Path.join(project, ".npm-args"))
    assert npm_args =~ "install"
    assert npm_args =~ "-D"
    assert npm_args =~ "tailwindcss-animate"
    refute File.exists?(Path.join(assets, ".npm-args"))

    app_css = File.read!(Path.join(assets, "css/app.css"))
    assert app_css =~ "@source \"../../deps/cinder_ui\";"
    assert app_css =~ "@import \"./cinder_ui.css\";"

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "import { CinderUIHooks } from \"./cinder_ui\""
    assert app_js =~ "Object.assign(Hooks, CinderUIHooks)"
  end

  test "creates assets package.json when no package manifests exist", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")

    write_fake_npm!(bin_dir)

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "npm"])
      end)
    end)

    assert File.exists?(Path.join(assets, "package.json"))
    assert File.read!(Path.join(assets, "package.json")) =~ "\"private\": true"
    npm_args = File.read!(Path.join(assets, ".npm-args"))
    assert npm_args =~ "install"
    assert npm_args =~ "-D"
    assert npm_args =~ "tailwindcss-animate"
  end

  test "skip-existing preserves generated files", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(Path.join(project, "package.json"), "{\n  \"private\": true\n}\n")
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")
    File.write!(Path.join(assets, "css/cinder_ui.css"), "/* sentinel css */\n")
    File.write!(Path.join(assets, "js/cinder_ui.js"), "// sentinel js\n")

    write_fake_npm!(bin_dir)

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)

        Mix.Task.run(@task, [
          "--assets-path",
          "assets",
          "--package-manager",
          "npm",
          "--skip-existing"
        ])
      end)
    end)

    assert File.read!(Path.join(assets, "css/cinder_ui.css")) == "/* sentinel css */\n"
    assert File.read!(Path.join(assets, "js/cinder_ui.js")) == "// sentinel js\n"
  end

  defp with_fake_path(bin_dir, fun) do
    original = System.get_env("PATH") || ""
    System.put_env("PATH", "#{bin_dir}:#{original}")

    try do
      fun.()
    after
      System.put_env("PATH", original)
    end
  end

  defp write_fake_npm!(bin_dir) do
    npm_path = Path.join(bin_dir, "npm")

    script = """
    #!/bin/sh
    printf "%s\\n" "$@" > "$PWD/.npm-args"
    exit 0
    """

    File.write!(npm_path, script)
    File.chmod!(npm_path, 0o755)
  end
end
