import random
import asyncio
from time import time
import pandas as pd
from dotenv import load_dotenv
# from mem0 import AsyncMemory
import click
from names_generator import generate_name
from google import genai
from google.genai import types

load_dotenv()

client = genai.Client()
# memory = AsyncMemory()

MODEL = "gemini-2.0-flash"

GENERATOR_INSTRUCTION = """
CHARACTER GENERATOR INSTRUCTIONS
---------------------------------
You are a character generator.

You will be told to create a character and will leverage the CHARACTER DATA DICTIONARY to create unique characters.

The user will provide you with the following prompt schema:

CREATE CHARACTER "<RANDOM CODENAME>" - "<ROLE>" - "<ALIGNMENT>"

Examples:

1:
CREATE CHARACTER "Vigorous Goldstein" - "Commander" - "Lawful Good"

2:
CREATE CHARACTER "Moby Meister" - "Special Forces Operator" - "Chaotic Good"

3:
CREATE CHARACTER "Baby Howie" - "Civilian" - "Chaotic Evil"

You will then make up a character based on the codename and the provided schema; the first and last name will be made up by you.

The characters will be used as NPCs in a game that is set in the not too distant future where players will accomplish missions across various theaters of war across the globe.

Maintain a consistent style and realistic tone for the characters; ensure that the characters are consistent with the game setting and are not generic or linked to common tropes.
"""

DUPLICATE_INSTRUCTIONS = """
DUPLICATE CHARACTER CASE HANDLING
---------------------------------
You are a character generator that is addressing duplicated character names and will output a new CHARACTER DATA DICTIONARY.

You will be provided the following prompt schema:

DUPLICATE FIRST NAME || DUPLICATE LAST NAME || "<CHARACTER NAME>" : {CHARACTER DATA DICTIONARY}
EXISTING FIRST NAMES || EXISTING LAST NAMES: [<LIST OF ALREADY USED NAMES TO NOT USE>]

Examples:

PROMPT 1:
DUPLICATE FIRST NAME "Moby" : {"first_name": "Moby", "last_name": "Richardson", ... }
EXISTING FIRST NAMES: [Moby, Jordan, Alex, John ...]

RESPONSE 1:
{"first_name": "Jackson", "last_name": "Donaldson", ... }

PROMPT 2:
DUPLICATE LAST NAME "Kristofferson" : {"first_name": "Sean", "last_name": "Kristofferson", ... }
EXISTING LAST NAMES: [Kristofferson, Richardson, Kowalski, ...]

RESPONSE 2:
{"first_name": "Adam", "last_name": "Gordon", ... }

It is important that you intake the list of already used names prior to generating a NEW NAME and NEW BIO that lines up with the CHARACTER DATA DICTIONARY and doesn't match any of the EXISTING NAMES.
"""

ROLES = [
    "Commander",
    "Special Forces Operator",
    "Sniper",
    "Medic",
    "Engineer",
    "Technician",
    "Support",
    "Recon",
    "Ranger",
    "Rogue",
    "Assassin",
    "Mercenary",
    "Pilot",
    "Artillery Specialist",
    "Logistics Specialist",
    "Civilian"
]

ALIGNMENTS = [
    "Lawful Good",
    "Neutral Good",
    "Chaotic Good",
    "Lawful Neutral",
    "True Neutral",
    "Chaotic Neutral",
    "Lawful Evil",
    "Neutral Evil",
    "Chaotic Evil"
]

SCHEMA_CONFIG = types.Schema(
    title='CHARACTER DATA DICTIONARY',
    description='A dictionary of character data that will be used to generate a character in a near future setting featuring global conflict.',
    type='object',
    properties={
        'first_name': {
            'type': 'string',
            'description': 'The first name of the character.'
        },
        'last_name': {
            'type': 'string',
            'description': 'The last name of the character.'
        },
        'codename': {
            'type': 'string',
            'description': 'The codename of the character passed in the prompt.'
        },
        'role': {
            'type': 'string',
            'description': 'The role of the character passed in the prompt.'
        },
        'bio': {
            'type': 'string',
            'description': 'The bio of the character in around 100 words. Avoid the overuse of adverbs and adjectives.'
        },
        'alignment': {
            'type': 'string',
            'enum': ALIGNMENTS,
            'description': 'The alignment of the character passed in the prompt.'
        },
        'personality': {
            'type': 'array',
            'min_items': 3,
            'max_items': 5,
            'items': {
                'type': 'string',
                'description': 'A personlaity trait of the character (e.g. "brave", "cautious", "greedy", "selfish", "kind").'
            },
            'description': 'The personality of the character; this is a list of personality traits that the character possesses.'
        },
        'interests': {
            'type': 'array',
            'min_items': 3,
            'max_items': 5,
            'items': {
                'type': 'string',
                'description': 'An interest of the character (e.g. "fishing", "hunting", "crafting", "cooking", "reading").'
            },
            'description': 'The interests of the character; this is a list of interests that the character possesses.'
        },
        'goals': {
            'type': 'array',
            'min_items': 2,
            'max_items': 5,
            'items': {
                'type': 'string',
                'description': 'A goal of the character (e.g. "help liberate a region", "start a revolution", "commit an act of terrorism", "secure resources for a war effort").'
            },
            'description': 'The goals of the character; this is a list of goals that the character possesses.'
        },
        'gender': {
            'type': 'string',
            'enum': ['male', 'female', 'other'],
            'description': 'The gender of the character.'
        },
        'age': {
            'type': 'integer',
            'description': 'The age of the character.'
        },
        'height': {
            'type': 'number',
            'description': 'The height of the character in centimeters.'
        },
        'weight': {
            'type': 'number',
            'description': 'The weight of the character in pounds.'
        },
        'health': {
            'type': 'integer',
            'description': 'The health points of the character.'
        },
        'stamina': {
            'type': 'integer',
            'description': 'The stamina points of the character.'
        },
        'tech_points': {
            'type': 'integer',
            'description': 'The tech points of the character.'
        },
        'attack': {
            'type': 'integer',
            'description': 'The attack points of the character.'
        },
        'defense': {
            'type': 'integer',
            'description': 'The defense points of the character.'
        }
    },
    required=['first_name', 'last_name', 'codename', 'bio', 'role', 'alignment', 'personality', 'interests', 'goals', 'gender', 'age', 'height', 'weight', 'health', 'stamina', 'tech_points', 'attack', 'defense'],
    property_ordering=['first_name', 'last_name', 'codename', 'role', 'bio', 'alignment', 'personality', 'interests', 'goals', 'gender', 'age', 'height', 'weight', 'health', 'stamina', 'tech_points', 'attack', 'defense']
)


async def generate_character(contents: str, duplicate_check: bool = False) -> types.GenerateContentResponse:
    """
    Generate a character based on the contents of the prompt.
    The contents of the prompt will be a string that will be used to generate the character.
    The character will be generated based on the system instruction and the schema config.
    The character will be returned as a GenerateContentResponse object.
    """

    seed = random.randint(0, 1000000)

    try:
        response = await client.aio.models.generate_content(
            model=MODEL,
            config=types.GenerateContentConfig(
                temperature=0.8,
                seed=seed,
                system_instruction=GENERATOR_INSTRUCTION if not duplicate_check else DUPLICATE_INSTRUCTIONS,
                response_mime_type='application/json',
                response_schema=SCHEMA_CONFIG
            ),
            contents=contents
        )
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

    return response


# async def get_memory() -> str:
#     pass


async def main() -> None:
    """
    Wrapper for running the async generate_character function n times.
    This function will prompt the user for the number of characters to generate,
    and then generate the characters.
    Generated characters will then be checked for duplicates and regenerated if necessary.
    The characters will be saved to a CSV file named "characters.csv" on the desktop.
    """
    duplicate_processing_tokens = 0
    duplicate_processing_token_cost = 0
    duplicate_loops = 0
    used_first_names = []
    used_last_names = []
    awaiting_input_prompt = True
    awaiting_sibling_prompt = True
    siblings_allowed = False

    # Helper Function
    async def duplicate_check(dict_data: dict) -> None:
        """
        Helper function that checks if the character data dictionary is a duplicate of any other character data dictionary.
        If it is, updates dict_data with a new character data dictionary, then calls itself again with the updated dict_data.
        If it is not, adds the character's full name to the used_names list and continues.

        Args:
            dict_data (dict): The character data dictionary to check for duplicates.

        Leverages:
            used_names (list): A list of used character names.
        """
        nonlocal duplicate_processing_tokens, duplicate_processing_token_cost, duplicate_loops

        try:
            first_name = dict_data['first_name']
            last_name = dict_data['last_name']
        except KeyError:
            click.echo(click.style("KeyError: That wasn't a valid character data dictionary", fg="red", bold=True))

        if first_name in used_first_names or (last_name in used_last_names and not siblings_allowed):
            if first_name in used_first_names:
                click.echo(click.style(f"{first_name} already used, generating new first name...", fg="red"))
                response = await generate_character(f'DUPLICATE FIRST NAME "{first_name}" : {dict_data} \nEXISTING FIRST NAMES: {random.shuffle(used_first_names)}', duplicate_check=True)
            else:
                click.echo(click.style(f"{last_name} already used, generating new last name...", fg="red"))
                response = await generate_character(f'DUPLICATE LAST NAME "{last_name}" : {dict_data} \nEXISTING LAST NAMES: {random.shuffle(used_last_names)}', duplicate_check=True)

            response_tokens = response.usage_metadata.total_token_count
            duplicate_processing_tokens += response_tokens
            duplicate_processing_token_cost += ((response_tokens / 1000000) * 0.10)
            duplicate_loops += 1

            dict_data.update(response.parsed)

            await duplicate_check(dict_data)

        used_first_names.append(first_name)
        used_last_names.append(last_name)

    while awaiting_input_prompt:
        input_prompt = input("How many characters would you like to generate?").strip()

        try:
            input_prompt = int(input_prompt)
            while awaiting_sibling_prompt:
                sibling_prompt = input("Would you like to generate sibling characters? (y/n)").strip().lower()
                if sibling_prompt == "y":
                    siblings_allowed = True
                    awaiting_sibling_prompt = False
                elif sibling_prompt == "n":
                    awaiting_sibling_prompt = False
                else:
                    click.echo(click.style("Please enter a valid response!", fg="red", bold=True))
            awaiting_input_prompt = False
        except ValueError:
            click.echo(click.style("Please enter a valid number!", fg="red", bold=True))

    start_time = time()

    jobs = [generate_character(f'CREATE CHARACTER "{generate_name(style='capital')}" - "{random.choice(ROLES)}" - "{random.choice(ALIGNMENTS)}"') for _ in range(input_prompt)]

    results = await asyncio.gather(*jobs)

    total_tokens = sum([result.usage_metadata.total_token_count for result in results])

    parsed_results = [result.parsed for result in results]

    for index, result in enumerate(parsed_results, 1):
        time_taken = time()
        click.echo(click.style("-----------------------------------------------------", fg="yellow", bold=True))
        click.echo(click.style(f"Checking for duplicates of character {index} of {input_prompt}...", fg="yellow"))
        click.echo(click.style("-----------------------------------------------------", fg="yellow", bold=True))
        await duplicate_check(result)
        time_taken = time() - time_taken

        if duplicate_processing_tokens > 0:
            click.echo(click.style("--------------------------------", fg="yellow", bold=True))
            if duplicate_loops > 10:
                click.echo(click.style('OOF THAT TOOK A WHILE! (SOMETHING MIGHT BE WRONG)', fg="red", bold=True))
            click.echo(click.style(f"NEW CHARACTER GENERATED! \nADDITIONAL TOKENS: {duplicate_processing_tokens} \nCOST: {duplicate_processing_token_cost:.2f} USD \nTIME TAKEN: {time_taken:.2f} seconds \nLOOPS: {duplicate_loops}", fg="green"))
            total_tokens += duplicate_processing_tokens
            duplicate_processing_tokens = 0
            duplicate_processing_token_cost = 0
            duplicate_loops = 0
        else:
            click.echo(click.style("NONE FOUND!", fg="green"))

    df = pd.DataFrame(parsed_results)

    df.to_csv("~/Desktop/characters.csv", index=False)

    token_cost = ((total_tokens / 1000000) * 0.10)

    click.echo(click.style("--------------------------------", fg="green", bold=True))
    click.echo(click.style(f"TOTAL TOKENS USED: {total_tokens}", fg="green", bold=True))
    click.echo(click.style(f"TOTAL TOKEN COST: {token_cost:.2f} USD", fg="green", bold=True))

    end_time = time()

    click.echo(click.style(f"TIME TAKEN: {end_time - start_time:.2f} seconds", fg="green"))

    if token_cost < 0.01:
        click.echo(click.style(f"Generating {input_prompt} characters resulted in a free run!", fg="green", bold=True))


if __name__ == "__main__":
    asyncio.run(main())
