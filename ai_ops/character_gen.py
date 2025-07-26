import random
import asyncio
from time import time
import pandas as pd
from dotenv import load_dotenv
import click
from pycountry import countries
from names_generator import generate_name
from google import genai
from google.genai import types

load_dotenv()

client = genai.Client()

MODEL = "gemini-2.0-flash"

GENERATOR_INSTRUCTION = """
CHARACTER GENERATOR INSTRUCTIONS
---------------------------------
You are a character generator.

You will be told to create a character and will leverage the CHARACTER DATA DICTIONARY to create unique characters.

The user will provide you with the following prompt schema:

CREATE CHARACTER "<RANDOM CODENAME>" - "<GENDER>" - "<ROLE>" - "<ALIGNMENT>" - "<COUNTRY>"

Examples:

1:
CREATE CHARACTER "Vigorous Goldstein" - "male" - "Commander" - "Lawful Good" - "Canada"

2:
CREATE CHARACTER "Solid Cobra" - "male" - "Special Forces Operator" - "Chaotic Good" - "India"

3:
CREATE CHARACTER "Baby Howie" - "male" - "Civilian" - "Chaotic Evil" - "United States"

You will then make up a character based on the codename and the provided schema; the first and last name will be made up by you.

The characters will be used as NPCs in a game that is set in the not too distant future where players will accomplish missions across various theaters of war across the globe.

Maintain a consistent style and realistic tone for the characters; ensure that the characters are consistent with the game setting and are not generic or linked to common tropes.
"""

DUPLICATE_INSTRUCTIONS = """
DUPLICATE CHARACTER CASE HANDLING
---------------------------------
You are a character generator that is addressing duplicated character names and will output a new CHARACTER DATA DICTIONARY.

You will be provided the following prompt schema:

DUPLICATE FIRST NAME || DUPLICATE LAST NAME || - NEW CODENAME "<NEW CODENAME>" - NEW COUNTRY "<NEW COUNTRY>": {CHARACTER DATA DICTIONARY}
EXISTING FIRST NAMES || EXISTING LAST NAMES: [<LIST OF ALREADY USED NAMES TO NOT USE>]

Examples:

PROMPT 1:
DUPLICATE FIRST NAME - NEW CODENAME "Silent Johnson" - NEW COUNTRY "United States" : {"first_name": "Moby", "last_name": "Richardson", ... }
EXISTING FIRST NAMES: [Moby, Jordan, Alex, John ...]

RESPONSE 1:
{"first_name": "Jackson", "last_name": "Donaldson", ... }

PROMPT 2:
DUPLICATE LAST NAME - NEW CODENAME "Dark Heisenberg" - NEW COUNTRY "Germany" : {"first_name": "Sean", "last_name": "Kristofferson", ... }
EXISTING LAST NAMES: [Kristofferson, Richardson, Kowalski, ...]

RESPONSE 2:
{"first_name": "Hans", "last_name": "Nudelman", ... }

It is important that you intake the list of already used names prior to generating a new CHARACTER DATA DICTIONARY with name properties that don't match any of the EXISTING NAMES.

Ensure that you also update the codename to the new codename provided and that all the other properties are consistent with the new name and bio and previously existing role and alignment.
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

OTHER_GENDERS = [
    "transgender male",
    "transgender female",
    "non-binary",
    "genderfluid",
    "intersex"
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
        'country': {
            'type': 'string',
            'description': 'The country of the character passed in the prompt.'
        },
        'role': {
            'type': 'string',
            'description': 'The role of the character passed in the prompt or previous character data dictionary.'
        },
        'gender': {
            'type': 'string',
            'description': 'The gender of the character passed in the prompt or previous character data dictionary.'
        },
        'age': {
            'type': 'integer',
            'description': 'The age of the character.'
        },
        'height': {
            'type': 'integer',
            'description': 'The height of the character in centimeters. Ensure that the height is realistic.'
        },
        'weight': {
            'type': 'integer',
            'description': 'The weight of the character in pounds. Ensure that the weight is realistic.'
        },
        'alignment': {
            'type': 'string',
            'enum': ALIGNMENTS,
            'description': 'The alignment of the character passed in the prompt.'
        },
        'bio': {
            'type': 'string',
            'description': 'The bio of the character in around 100 words. Avoid the overuse of adverbs and adjectives.'
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
    required=['first_name', 'last_name', 'codename', 'country', 'gender', 'bio', 'role', 'alignment', 'personality', 'interests', 'goals', 'age', 'height', 'weight', 'health', 'stamina', 'tech_points', 'attack', 'defense'],
    property_ordering=['first_name', 'last_name', 'codename', 'country', 'role', 'gender', 'age', 'height', 'weight', 'alignment', 'bio', 'personality', 'interests', 'goals', 'health', 'stamina', 'tech_points', 'attack', 'defense']
)


# Random Country Generator
def generate_country() -> str:
    """
    Generate a country name.
    """
    return random.choice(list(countries)).name


# Random Gender Generator
def generate_gender() -> str:
    """
    Generate a gender based on realistic distribution.
    """
    gender_distribution = {
        "male": 49.5,
        "female": 49.5,
        "other": 1,
    }

    total = sum(gender_distribution.values())
    normalized_distribution = {gender: percentage / total for gender, percentage in gender_distribution.items()}

    selected_gender = random.choices(
        population=list(normalized_distribution.keys()),
        weights=list(normalized_distribution.values())
    )[0]

    if selected_gender == "other":
        return random.choice(OTHER_GENDERS)
    else:
        return selected_gender


# Character Generator Agent
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

    # Duplicate Check Helper Function
    async def duplicate_check(character_data: dict) -> None:
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
            first_name = character_data['first_name']
            last_name = character_data['last_name']
        except KeyError:
            click.echo(click.style("KeyError: That wasn't a valid character data dictionary", fg="red", bold=True))

        if first_name in used_first_names or (last_name in used_last_names and not siblings_allowed):
            if first_name in used_first_names:
                click.echo(click.style(f"{first_name} already used, generating new first name...", fg="red"))
                response = await generate_character(f'DUPLICATE FIRST NAME - NEW CODENAME "{generate_name(style="capital")}" - NEW COUNTRY "{generate_country()}" : {character_data} \nEXISTING FIRST NAMES: {random.shuffle(used_first_names)}', duplicate_check=True)
            else:
                click.echo(click.style(f"{last_name} already used, generating new last name...", fg="red"))
                response = await generate_character(f'DUPLICATE LAST NAME - NEW CODENAME "{generate_name(style="capital")}" - NEW COUNTRY "{generate_country()}" : {character_data} \nEXISTING LAST NAMES: {random.shuffle(used_last_names)}', duplicate_check=True)

            response_tokens = response.usage_metadata.total_token_count
            duplicate_processing_tokens += response_tokens
            duplicate_processing_token_cost += ((response_tokens / 1000000) * 0.10)
            duplicate_loops += 1

            character_data.update(response.parsed)

            await duplicate_check(character_data)

        used_first_names.append(first_name)
        used_last_names.append(last_name)

    while awaiting_input_prompt:
        input_prompt = input("How many characters would you like to generate? ").strip()

        try:
            input_prompt = int(input_prompt)

            while awaiting_sibling_prompt:
                sibling_prompt = input("Would you like to generate sibling characters? (y/n) ").strip().lower()

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

    click.echo(click.style(f"Generating {input_prompt} characters...", fg="green", bold=True))

    jobs = [generate_character(f'CREATE CHARACTER "{generate_name(style="capital")}" - "{generate_gender()}" - "{random.choice(ROLES)}" - "{random.choice(ALIGNMENTS)}" - "{generate_country()}"') for _ in range(input_prompt)]

    results = await asyncio.gather(*jobs)

    click.echo(click.style("-----------------------------------------------------", fg="green", bold=True))
    click.echo(click.style(f"ASYNC GENERATION COMPLETE! \nTIME TAKEN: {time() - start_time:.2f} seconds", fg="green", bold=True))
    click.echo(click.style("-----------------------------------------------------", fg="green", bold=True))

    total_tokens = sum([result.usage_metadata.total_token_count for result in results])

    characters = [result.parsed for result in results]

    # Duplicate Check
    for index, character in enumerate(characters, 1):
        click.echo(click.style("-----------------------------------------------------", fg="yellow", bold=True))
        click.echo(click.style(f"Checking for duplicates of character {index} of {input_prompt}...", fg="yellow"))
        click.echo(click.style(f"----------------------------------------------------- >>> {time() - start_time:.2f} seconds elapsed <<<", fg="yellow", bold=True))
        time_taken = time()
        await duplicate_check(character)
        time_taken = time() - time_taken

        if duplicate_processing_tokens > 0:
            click.echo(click.style("-------", fg="yellow", bold=True))
            if duplicate_loops > 10:
                click.echo(click.style('OOF THAT TOOK A WHILE! (SOMETHING MIGHT BE WRONG)', fg="red", bold=True))
            click.echo(click.style(f"NEW CHARACTER GENERATED! \nADDITIONAL TOKENS: {duplicate_processing_tokens} \nCOST: {duplicate_processing_token_cost:.2f} USD \nTIME TAKEN: {time_taken:.2f} seconds \nLOOPS: {duplicate_loops}", fg="green"))
            total_tokens += duplicate_processing_tokens
            duplicate_processing_tokens = 0
            duplicate_processing_token_cost = 0
            duplicate_loops = 0
        else:
            click.echo(click.style("NONE FOUND!", fg="green"))

    end_time = time()

    df = pd.DataFrame(characters)

    df.to_csv("~/Desktop/characters.csv", index=False)

    total_token_cost = ((total_tokens / 1000000) * 0.10)

    click.echo(click.style("-----------------------------------------------------", fg="green", bold=True))
    click.echo(click.style(f"TOTAL TOKENS USED: {total_tokens}", fg="green", bold=True))
    click.echo(click.style(f"TOTAL TOKEN COST: {total_token_cost:.2f} USD", fg="green", bold=True))
    click.echo(click.style(f"TIME TAKEN: {end_time - start_time:.2f} seconds", fg="green", bold=True))

    if total_token_cost < 0.01:
        click.echo(click.style("-----------------------------------------------------", fg="green", bold=True))
        click.echo(click.style(f"Generating {input_prompt} characters resulted in a free-ish run!", fg="green", bold=True))


if __name__ == "__main__":
    asyncio.run(main())
