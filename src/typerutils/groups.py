from typer.core import TyperGroup


class NaturalOrderGroup(TyperGroup):
    def list_commands(self, __ctx__):  # pyright: ignore[reportIncompatibleMethodOverride]
        return self.commands.keys()
