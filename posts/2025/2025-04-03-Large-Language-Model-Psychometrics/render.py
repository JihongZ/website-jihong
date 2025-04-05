backslash ="\n\t"
def render(data: str) -> str:
    data_dict = json.loads(data)

    return f"""
    <ul>
        {"{backslash}".join([ f"<li>{x}</li>" for x in data_dict["groceries"]])}
    </ul>
    """
