from typerutils import create_app
from typerutils.testing import invoke


def test_create_app_completion_default_enabled():
    result = invoke(defaultapp, "")
    assert result.exit_code == 0
    assert "Install completion for the current shell" not in result.stdout


def test_create_app_completion_override():
    result = invoke(overrideapp, "")
    assert result.exit_code == 0
    assert "Install completion for the current shell" in result.stdout


defaultapp = create_app()


@defaultapp.command()
def hello1():
    print("Hello!")


@defaultapp.command()
def world1():
    print("Hello World")


overrideapp = create_app(
    add_completion=True,
)


@overrideapp.command()
def hello2():
    print("Hello!")


@overrideapp.command()
def world2():
    print("Hello World")
