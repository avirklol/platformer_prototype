import random
import asyncio
import pandas as pd
from time import time
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

SYSTEM_INSTRUCTION = """
CORE INSTRUCTIONS
---------------------------------
You are a character generator.

You will be told to create a character and will leverage the provided schema to create unique characters.

The user will provide you with the following prompt schema:

CREATE CHARACTER <RANDOM CODENAME> <ROLE> <ALIGNMENT>

Examples:

1:
CREATE CHARACTER "Vigorous Goldstein" - "Commander" - "Lawful Good"

2:
CREATE CHARACTER "Moby Meister" - "Special Forces Operator" - "Chaotic Good"

3:
CREATE CHARACTER "Baby Howie" - "Civilian" - "Chaotic Evil"

You will then make up a character based on the codename and the provided schema; the first and last name will be made up by you.

The characters will be used in a game that is set in the not too distant future where players control a super soldier that will accomplish missions across various theaters of war across the globe.
Maintain a consistent style and realistic tone for the characters; ensure that the characters are consistent with the game setting and are not generic or linked to common tropes.


DUPLICATE CHARACTER CASE HANDLING
---------------------------------
Since you're an asynchronous agent, you may generate the same character multiple times. We'll catch this and follow up with the following prompt schema:

DUPLICATE CHARACTER <CHARACTER NAME> : <CHARACTER DATA DICTIONARY>
[<OTHER CREATED CHARACTER NAMES>]

Examples:

1:
DUPLICATE CHARACTER "Marcus Cole" : {"first_name": "Moby", "last_name": "Meister", "bio": "Moby Meister is...", ... }
[Kenzo Tanaka, Jordan Hayes, ...]

2:
DUPLICATE CHARACTER "Kenzo Tanaka" : {"first_name": "Baby", "last_name": "Howie", "bio": "Baby Howie is...", ... }
[Cassius Claye, Julia Kowalski, ...]

In this case, all you'll need to do is generate a new first and last name that lines up with the character data dictionary and doesn't match any of the other created character names.
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
        'bio': {
            'type': 'string',
            'description': 'The bio of the character in around 100 words.'
        },
        'alignment': {
            'type': 'string',
            'enum': ALIGNMENTS,
            'description': 'The alignment of the character.'
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
            'min_items': 3,
            'max_items': 5,
            'items': {
                'type': 'string',
                'description': 'A goal of the character (e.g. "hunt a great beast", "find a lost relic", "root out all evil").'
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
        },
        'level': {
            'type': 'integer',
            'description': "The level of the character; this is the level of the character in the game. Ensure it's scaled to the character's stats."
        },
        'experience': {
            'type': 'integer',
            'description': 'The experience points of the character in accordance to the character\'s level.'
        },
    },
    required=['first_name', 'last_name', 'bio', 'alignment', 'personality', 'interests', 'goals', 'gender', 'age', 'height', 'weight', 'health', 'stamina', 'tech_points', 'attack', 'defense', 'level', 'experience'],
    property_ordering=['first_name', 'last_name', 'bio', 'alignment', 'personality', 'interests', 'goals', 'gender', 'age', 'height', 'weight', 'health', 'stamina', 'tech_points', 'attack', 'defense', 'level', 'experience']
)

character_generator = client.aio.chats.create(
    model=MODEL,
    config=types.GenerateContentConfig(
        temperature=0.7,
        system_instruction=SYSTEM_INSTRUCTION,
        response_mime_type='application/json',
        response_schema=SCHEMA_CONFIG
    )
)


async def generate_character(contents: str) -> types.GenerateContentResponse:
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
                temperature=0.75,
                seed=seed,
                system_instruction=SYSTEM_INSTRUCTION,
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

    used_full_names = []
    used_first_names = []
    used_last_names = []
    awaiting_input = True

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
        try:
            first_name = dict_data['first_name']
            last_name = dict_data['last_name']
            full_name = f"{first_name} {last_name}"
        except KeyError:
            click.echo(click.style("KeyError: That wasn't a valid character data dictionary", fg="red", bold=True))

        if full_name in used_full_names or first_name in used_first_names or last_name in used_last_names:
            if first_name in used_first_names:
                click.echo(click.style(f"{first_name} already used, generating new first name...", fg="red", bold=True))
                response = await generate_character(f"DUPLICATE CHARACTER {full_name} : {dict_data} \n {used_first_names}")
            elif last_name in used_last_names:
                click.echo(click.style(f"{last_name} already used, generating new last name...", fg="red", bold=True))
                response = await generate_character(f"DUPLICATE CHARACTER {full_name} : {dict_data} \n {used_last_names}")
            else:
                click.echo(click.style(f"{full_name} already used, generating new name...", fg="red", bold=True))
                response = await generate_character(f"DUPLICATE CHARACTER {full_name} : {dict_data} \n {used_full_names}")

            dict_data.update(response.parsed)

            await duplicate_check(dict_data)

        used_full_names.append(full_name)
        used_first_names.append(first_name)
        used_last_names.append(last_name)

    while awaiting_input:
        input_prompt = input("How many characters would you like to generate? ")

        try:
            input_prompt = int(input_prompt)
            awaiting_input = False
        except ValueError:
            print("Please enter a valid number!")

    start_time = time()

    jobs = [generate_character(f"CREATE CHARACTER {generate_name(style='capital')} - {random.choice(ROLES)} - {random.choice(ALIGNMENTS)}") for _ in range(input_prompt)]

    results = await asyncio.gather(*jobs)

    parsed_results = [result.parsed for result in results]

    for result in parsed_results:
        await duplicate_check(result)

    df = pd.DataFrame(parsed_results)

    df.to_csv("~/Desktop/characters.csv", index=False)

    token_cost = ((sum([result.usage_metadata.total_token_count for result in results]) / 1000000) * 0.10)

    click.echo(click.style(f"Total token cost: {token_cost:.2f} USD", fg="green"))

    end_time = time()

    click.echo(click.style(f"Time taken: {end_time - start_time:.2f} seconds", fg="green"))

    if token_cost < 0.01:
        click.echo(click.style(f"{input_prompt} CHARACTERS GENERATED FOR FUCKING FREEEEEEE. WHAT A TIME TO BE ALIVE.", fg="green", blink=True, bold=True))


if __name__ == "__main__":
    asyncio.run(main())
