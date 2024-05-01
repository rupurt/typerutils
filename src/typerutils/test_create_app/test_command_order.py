import re

from typerutils import create_app
from typerutils.testing import invoke


def test_command_order_default_natural():
    result = invoke(defaultapp, "")
    assert result.exit_code == 0
    assert re.match(r"^.+foo1.+bar1.+$", result.stdout, re.DOTALL)


def test_command_order_override():
    result = invoke(overrideapp, "")
    assert result.exit_code == 0
    assert re.match(r"^.+bar2.+foo2.+$", result.stdout, re.DOTALL)


defaultapp = create_app()


@defaultapp.command()
def foo1():
    print("Foo!")


@defaultapp.command()
def bar1():
    print("Bar!")


overrideapp = create_app(cls=None)


@overrideapp.command()
def foo2():
    print("Foo!")


@overrideapp.command()
def bar2():
    print("Bar!")
