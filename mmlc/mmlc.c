/**
 * mml compiler for SuperC main program
 *
 */

#include "gstdafx.h"
#include "mmlc.h"
#include "compile.h"
#include "mmlman.h"
#include "binaryman.h"
#include "spc.h"
#include "snsf.h"
#include "errorman.h"
#include "timefunc.h"
#include "pathfunc.h"

#define BRR_BUF 2048
#define DATA_BUFFER_SIZE 0x40000

/************************************************************/
/* オプション関連定義                                       */
/************************************************************/
enum{
	OPT_Nolink = 1,
	OPT_SNSF,
	OPT_ROM,
	OPT_Debug,
	OPT_Help,
	OPT_Version,
};
typedef enum{
	MAKE_SPC = 0,
	MAKE_BIN,
	MAKE_SNSF,
	MAKE_ROM,
}MakeType;
static const Option Opt[] = {
	{OPT_Nolink, "compileonly", 'c', "compile only, not make spc"},
	{OPT_SNSF, "snsf", 's', "generate snsf file."},
	{OPT_ROM, "rom", 'r', "generate rom image."},
	{OPT_Debug, "debug", 'd', "verbose debug info"},
	{OPT_Help, "help", '?', "show usage"},
	{OPT_Version, "version", 'v', "show version"},
	{0, NULL, 0, NULL}
};

bool helped = false;
bool vdebug = false; /* TODO: リリース時はfalseにする */
MakeType type = MAKE_SPC;
char* in_file_name = NULL;
char* out_file_name = NULL;

/******************************************************************************/


/**************************************************************/
/* バージョン情報出力                                         */
/**************************************************************/
#define printVersion() \
	printf("mmlc for SuperC SPC Driver v%s\n", MMLCONV_VERSION);\
	printf("  by boldowa\n");\
	printf("  since    : Sep 02 2010\n");\
	printf("  compiled : %s\n", __DATE__);\


/**************************************************************/
/* 使い方表示                                                 */
/*   program : プログラム名                                   */
/**************************************************************/
void printUsage(const char* program)
{
	const Option *op;
	printf("Usage: %s [options] input-file output-file\n", program);
	printf("Options:\n");
	for(op = Opt; op->id != 0; op++)
	{
		printf("  -%c, --%-14s %.45s\n", op->sname, op->name, op->description);
	}
}

/**************************************************************/
/* オプション展開                                             */
/*   argc : オプション引数個数                                */
/*   argv : オプション引数                                    */
/**************************************************************/
bool parseOption(const int argc, const char **argv)
{
	int ind;
	bool err = false;
	const Option *op;
	int op_id;
	char *cmd = NULL;

	ind=1;
	while(ind<argc)
	{
		op_id = 0;
		cmd = (char*)argv[ind++];
		if(cmd[0] == '-')
		{
			for(op = Opt; op->id != 0; op++)
			{
				if(cmd[1] == '-')
				{
					if(!strcmp(cmd+2, op->name))
						op_id = op->id;
				}
				else
				{
					if(cmd[1] == op->sname && cmd[2] == '\0')
						op_id = op->id;
				}
			} /* op loop */
			if(!op_id){
				puterror("Invalid command %s", cmd);
				err = true;
			}
			switch(op_id)
			{
			case OPT_Help:
				printUsage(argv[0]);
				helped = true;
				return true;
			case OPT_Version:
				printVersion();
				helped = true;
				return true;
			case OPT_Debug:
				vdebug = true;
				break;
			case OPT_Nolink:
				type = MAKE_BIN;
				break;
			case OPT_SNSF:
				type = MAKE_SNSF;
				break;
			case OPT_ROM:
				type = MAKE_ROM;
				break;
			default:
				break;
			}
		}
		else
		{
			if(!in_file_name)
			{
				in_file_name = cmd;
			}
			else if(!out_file_name)
			{
				out_file_name = cmd;
			}
			else
			{
				puts("Error: too many argument.");
				err = true;
			}
		}
	} /* argc loop */
	if(!in_file_name)
	{
		puterror("Missing input-file argument.");
		err = true;
	}
	if(!out_file_name)
	{
		puterror("Missing output-file argument.");
		err = true;
	}
	if(err)
	{
		puts("Please try '-?' or '--help' option, and you can get more information.");
		return false;
	}
	putdebug("--- Option parse complete.");
	putdebug("--- Input file  : \"%s\"", in_file_name);
	putdebug("--- Output file : \"%s\"", out_file_name);
	return true;
}

/**
 * コンパイルエラーを表示します
 */
void showCompileError(ErrorNode* err, char* fname)
{
	/**
	 * 現在出力中のエラー
	 */
	ErrorNode* curErr = NULL;

	curErr = err;
	while(curErr != NULL)
	{
		/* エラーレベル毎に出力フォーマットを変更して */
		/* エラーを表示します                         */
		switch(curErr->level)
		{
			case ERR_DEBUG:
				putmmldebug(curErr->date, fname, curErr->line, curErr->column, curErr->message);
				break;
			case ERR_INFO:
				putmmlinfo(curErr->date, fname, curErr->line, curErr->column, curErr->message);
				break;
			case ERR_WARN:
				putmmlwarn(curErr->date, fname, curErr->line, curErr->column, curErr->message);
				break;
			case ERR_ERROR:
				putmmlerror(curErr->date, fname, curErr->line, curErr->column, curErr->message);
				break;
			case ERR_FATAL:
				putmmlfatal(curErr->date, fname, curErr->line, curErr->column, curErr->message);
				break;
			default:
				putmmlunknown(curErr->date, fname, curErr->line, curErr->column, curErr->message);
				break;
		}

		/* 次のエラーを取得します */
		curErr = curErr->nextError;
	}

	return;
}

/**************************************************************/
/* メイン関数                                                 */
/*   argc : オプション引数個数                                */
/*   argv : オプション引数                                    */
/**************************************************************/
int main(const int argc, const char** argv)
{
	FILE *outf = NULL;
	ErrorNode* errList = NULL;
	ErrorLevel errLevel = ERR_DEBUG;
	MmlMan mml;
	BinMan binary;
	TIME startTime, endTime;
	stBrrListData *brrList = NULL;
	byte genDataBuffer[DATA_BUFFER_SIZE];
	stSpcCore spcCore;
	char spcCorePath[MAX_PATH];

	getTime(&startTime);

	/* 初期化 */
	memset(&mml, 0, sizeof(MmlMan));
	memset(&binary, 0, sizeof(BinMan));
	memset(genDataBuffer, 0xff, DATA_BUFFER_SIZE);

	/* オプション展開 */
	if(!parseOption(argc, argv))
	{
		return -1;
	}
	if(helped) /* Show Usage && Show version */
	{
		return 0;
	}

	/* 実行ファイルのあるディレクトリを取得します */
	getFileDir(spcCorePath, argv[0]);
	/* SPCドライバコアファイルパスをセットします */
	strcat(spcCorePath, "spccore.bin");
	/* SPCドライバコアファイルを読み込みます */
	if(false == coreread(&spcCore, spcCorePath))
	{
		putfatal("Can't read \"%s\".", spcCorePath);
		return -1;
	}
	printf("spc core Version: %02x.%02x\n", spcCore.ver, spcCore.verMiner);

	/* mmlファイルを読出します */
	if(mmlopen(&mml, in_file_name) == false)
	{
		puterror("Input file \"%s\" is not found.", in_file_name);
		freecore(&spcCore);
		return -1;
	}
	putdebug("--- MML read success.");

	/* 変換バッファを作成します */
	if(bininit(&binary) == false)
	{
		mmlclose(&mml);
		freecore(&spcCore);
		puterror("Memory capacity over.");
		return -1;
	}
	putdebug("--- Create compile buffer success.");

	/* 出力先ファイルをあらかじめロックします */
	if(!(outf = fopen(out_file_name, "wb")))
	{
		binfree(&binary);
		mmlclose(&mml);
		freecore(&spcCore);
		puterror("Output file \"%s\" couldn't open.", out_file_name);
		return -1;
	}
	putdebug("--- Output file create success.");

	/* mmlをコンパイルします */
	putdebug("########## COMPILE START ##########");
	errList = compile(&mml, &binary, &brrList);
	if(errList != NULL)
	{
		/* エラーレベルを取得します */
		errLevel = getErrorLevel(errList);

		/* エラーを表示します */
		showCompileError(errList, mml.fname);

		/* エラー表示用に確保したメモリを解放します */
		errorclear(errList);
	}
	if(errLevel >= ERR_ERROR)
	{ /* コンパイルエラー */
		putdebug("########## COMPILE ERROR ##########");
		puts("Compile failed...");
		deleteBrrListData(brrList);
		mmlclose(&mml);
		binfree(&binary);
		fclose(outf);
		freecore(&spcCore);
		remove(out_file_name);
		return -1;
	}

	switch(type)
	{
		case MAKE_SPC:
		{
			/* SPCデータを生成します */
			if(false == makeSPC(genDataBuffer, &spcCore, &mml, &binary, brrList))
			{
				puterror("makeSPC failed.");
				deleteBrrListData(brrList);
				mmlclose(&mml);
				binfree(&binary);
				fclose(outf);
				freecore(&spcCore);
				remove(out_file_name);
				return -1;
			}

			/* SPCデータを書き出します */
			/* fwrite(binary.data, sizeof(byte), binary.dataInx, outf); */
			fwrite(genDataBuffer, sizeof(byte), 0x10200, outf);
		}
		break;

		case MAKE_BIN:
		{
			int sz;
			sz = makeBin(genDataBuffer, &spcCore, &mml, &binary, brrList);
			if(0 == sz)
			{
				puterror("makeBin failed.");
				deleteBrrListData(brrList);
				mmlclose(&mml);
				binfree(&binary);
				fclose(outf);
				freecore(&spcCore);
				remove(out_file_name);
				return -1;
			}

			fwrite(genDataBuffer, sizeof(byte), sz, outf);
		}
		break;

		case MAKE_SNSF:
		{
			int sz;
			sz = makeSNSF(genDataBuffer, &spcCore, &mml, &binary, brrList);
			if(0 == sz)
			{
				puterror("makeSNSF failed.");
				deleteBrrListData(brrList);
				mmlclose(&mml);
				binfree(&binary);
				fclose(outf);
				freecore(&spcCore);
				remove(out_file_name);
				return -1;
			}

			fwrite(genDataBuffer, sizeof(byte), sz, outf);
		}
		break;

		case MAKE_ROM:
		{
			int result;
			result = buildSnes(genDataBuffer, &spcCore, &mml, &binary, brrList);
			if(0 == result)
			{
				puterror("makeROM failed.");
				deleteBrrListData(brrList);
				mmlclose(&mml);
				binfree(&binary);
				fclose(outf);
				freecore(&spcCore);
				remove(out_file_name);
				return -1;
			}

			fwrite(genDataBuffer, sizeof(byte), ROMSIZE, outf);
		}
		break;
	}
	fclose(outf);

	/* 終了処理 */
	deleteBrrListData(brrList);
	mmlclose(&mml);
	binfree(&binary);
	freecore(&spcCore);
	putdebug("########## COMPILE SUCCESS ##########");

	getTime(&endTime);
	printf("\nComplete. Compiled in %.3f seconds.\n", getTimeToPass(&startTime, &endTime));

	return 0;
}

