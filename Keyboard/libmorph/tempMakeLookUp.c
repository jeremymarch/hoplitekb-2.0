#include "accent.h"
#include "GreekUnicode.h"

/*
gcc -std=c99 tempMakeLookUp.c utilities.c accent.c -I.. -o mklup
*/
#define ALLOW_PRIVATE_USE_AREA 1
#define NUM_VOWEL_CODES 14
#define NUM_ACCENT_CODES 39

extern unsigned short letters[NUM_VOWEL_CODES][NUM_ACCENT_CODES];

char *ln[] = {"ALPHA", "EPSILON", "ETA", "IOTA", "OMICRON", "UPSILON", "OMEGA", "ALPHA_CAP", "EPSILON_CAP", "ETA_CAP", "IOTA_CAP", "OMICRON_CAP", "UPSILON_CAP", "OMEGA_CAP" };
char *dn[] = { "NORMAL",
 	"TONOS",
    "DIALYTIKA_AND_TONOS",
    "PSILI",                                  //smooth
    "DASIA",                                  //rough
    "OXIA",
    "PSILI_AND_OXIA",
    "DASIA_AND_OXIA",
    "VARIA",
    "PSILI_AND_VARIA",
    "DASIA_AND_VARIA",
    "PERISPOMENI",
    "PSILI_AND_PERISPOMENI",
    "DASIA_AND_PERISPOMENI",
    "YPOGEGRAMMENI",
    "PSILI_AND_YPOGEGRAMMENI",
    "DASIA_AND_YPOGEGRAMMENI",
    "OXIA_AND_YPOGEGRAMMENI",
    "PSILI_AND_OXIA_AND_YPOGEGRAMMENI",
    "DASIA_AND_OXIA_AND_YPOGEGRAMMENI",
    "VARIA_AND_YPOGEGRAMMENI",
    "PSILI_AND_VARIA_AND_YPOGEGRAMMENI",
    "DASIA_AND_VARIA_AND_YPOGEGRAMMENI",
    "PERISPOMENI_AND_YPOGEGRAMMENI",
    "PSILI_AND_PERISPOMENI_AND_YPOGEGRAMMENI",
    "DASIA_AND_PERISPOMENI_AND_YPOGEGRAMMENI",
    "DIALYTIKA",
    "DIALYTIKA_AND_OXIA",
    "DIALYTIKA_AND_VARIA",
    "DIALYTIKA_AND_PERISPOMENON",
    "MACRON_PRECOMPOSED",
#ifdef ALLOW_PRIVATE_USE_AREA
    "MACRON_AND_SMOOTH",
    "MACRON_AND_SMOOTH_AND_ACUTE",
    "MACRON_AND_SMOOTH_AND_GRAVE",
    "MACRON_AND_ROUGH",
    "MACRON_AND_ROUGH_AND_ACUTE",
    "MACRON_AND_ROUGH_AND_GRAVE",
    "MACRON_AND_ACUTE",
    "MACRON_AND_GRAVE"
#endif
};

char *dn2[] = { "0",
 	"_ACUTE",
    "_ACUTE | _DIAERESIS",
    "_SMOOTH",                                  //smooth
    "_ROUGH",                                  //rough
    "_ACUTE",
    "_SMOOTH | _ACUTE",
    "_ROUGH | _ACUTE",
    "_GRAVE",
    "_SMOOTH | _GRAVE",
    "_ROUGH | _GRAVE",
    "_CIRCUMFLEX",
    "_SMOOTH | _CIRCUMFLEX",
    "_ROUGH | _CIRCUMFLEX",
    "_IOTA_SUB",
    "_SMOOTH | _IOTA_SUB",
    "_ROUGH | _IOTA_SUB",
    "_ACUTE | _IOTA_SUB",
    "_SMOOTH | _ACUTE | _IOTA_SUB",
    "_ROUGH | _ACUTE | _IOTA_SUB",
    "_GRAVE | _IOTA_SUB",
    "_SMOOTH | _GRAVE | _IOTA_SUB",
    "_ROUGH | _GRAVE | _IOTA_SUB",
    "_CIRCUMFLEX | _IOTA_SUB",
    "_SMOOTH | _CIRCUMFLEX | _IOTA_SUB",
    "_ROUGH | _CIRCUMFLEX | _IOTA_SUB",
    "_DIAERESIS",
    "_DIAERESIS | _ACUTE",
    "_DIAERESIS | _GRAVE",
    "_DIAERESIS | _CIRCUMFLEX",
    "_MACRON",
#ifdef ALLOW_PRIVATE_USE_AREA
    "_MACRON | _SMOOTH",
    "_MACRON | _SMOOTH | _ACUTE",
    "_MACRON | _SMOOTH | _GRAVE",
    "_MACRON | _ROUGH",
    "_MACRON | _ROUGH | _ACUTE",
    "_MACRON | _ROUGH | _GRAVE",
    "_MACRON | _ACUTE",
    "_MACRON | _GRAVE"
#endif
};

char *head[] = {"short basicGreekLookUp[][2] = {", "short extendedGreekLookUp[][2] = {", "short puaGreekLookUp[][2] = {"};

int ranges[3][2] = { 
	{ 0x0370, 0x03FF },
	{ 0x1F00, 0x1FFF },
	{ 0xEAF0, 0xEB80 }
};

int main(int argc, char **argv)
{
	//for each range
	for (int a = 0; a < 3; a++)
	{
		printf("%s\n", head[a]);

		for (int i = ranges[a][0]; i <= ranges[a][1]; i++)
		{
			int letter = 0;
			int diacritic = 0;
			int found = 0;

			//for each letter
			for (int j = 0; j < NUM_VOWEL_CODES; j++)
			{
				//for each diacritic form
				for (int k = 0; k < NUM_ACCENT_CODES; k++)
				{
					if ( i == letters[j][k] )
					{
						letter = j;
						diacritic = k;
						
						//printf("/* %4x */ [%s,%d]\n", i, ln[j], k);
						found = 1;
						break;
					}
				}
				if (found)
				{
					break;
				}

			}
			if (found)
			{
				printf("/* %04X */ { %s, %s }", i, ln[letter], dn2[diacritic]);
			}
			else
			{
				printf("/* %04X */ { %s, %s }", i, "NOCHAR", "NOCHAR");
			}

			if (i == ranges[a][1])
			{
				printf("\n");
			}
			else
			{
				printf(",\n");
			}
			found = 0;
			letter = 0;
			diacritic = 0;
		}

		printf("};\n\n");
	}
	return 0;
}
