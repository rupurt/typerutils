import typer
from typerutils.groups import NaturalOrderGroup


def create_app(
    add_completion=False,
    no_args_is_help=True,
    context_settings=dict(help_option_names=["-h", "--help"]),
    cls=NaturalOrderGroup,
) -> typer.Typer:
    return typer.Typer(
        add_completion=add_completion,
        no_args_is_help=no_args_is_help,
        context_settings=context_settings,
        cls=cls,
    )
