from typerutils import create_app
from typerutils.testing import invoke


def test_no_args_is_help_default_enabled():
    result = invoke(defaultapp, "")
    assert result.exit_code == 0
    assert "Usage:" in result.stdout


def test_no_args_is_help_override():
    result = invoke(overrideapp, "")
    assert result.exit_code != 0


def test_short_and_long_help_default_enabled():
    result = invoke(defaultapp, "-h")
    assert result.exit_code == 0
    assert "Usage:" in result.stdout
    result = invoke(defaultapp, "--help")
    assert result.exit_code == 0
    assert "Usage:" in result.stdout


def test_help_override():
    result = invoke(overrideapp, "-h")
    assert result.exit_code != 0
    result = invoke(overrideapp, "--help")
    assert result.exit_code != 0
    result = invoke(overrideapp, "--helpme")
    assert result.exit_code == 0


defaultapp = create_app()


@defaultapp.command()
def hello1():
    print("Hello!")


@defaultapp.command()
def world1():
    print("Hello World")


overrideapp = create_app(
    no_args_is_help=False,
    context_settings=dict(help_option_names=["--helpme"]),
)


@overrideapp.command()
def hello2():
    print("Hello!")


@overrideapp.command()
def world2():
    print("Hello World")
