/*
 *  ReactOS Task Manager
 *
 *  column.c
 *
 *  Copyright (C) 1999 - 2001  Brian Palmer  <brianp@reactos.org>
 *                2005         Klemens Friedl <frik85@reactos.at>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "taskmgr.h"

UINT    ColumnDataHints[COLUMN_NMAX];

#define DECLARE_COLUMN_PRESET(_name, _size, _state) \
    { IDS_TAB_##_name, IDC_##_name, _size, _state },

const PresetColumnEntry ColumnPresets[COLUMN_NMAX] = 
{
    DECLARE_COLUMN_PRESET(IMAGENAME,         105, TRUE)
    DECLARE_COLUMN_PRESET(PID,               50,  TRUE)
    DECLARE_COLUMN_PRESET(USERNAME,          70,  TRUE)
    DECLARE_COLUMN_PRESET(SESSIONID,         70,  FALSE)
    DECLARE_COLUMN_PRESET(CPUUSAGE,          35,  TRUE)
    DECLARE_COLUMN_PRESET(CPUTIME,           70,  FALSE)
    DECLARE_COLUMN_PRESET(MEMORYUSAGE,       70,  TRUE)
    DECLARE_COLUMN_PRESET(PEAKMEMORYUSAGE,   100, FALSE)
    DECLARE_COLUMN_PRESET(MEMORYUSAGEDELTA,  70,  FALSE)
    DECLARE_COLUMN_PRESET(PAGEFAULTS,        70,  FALSE)
    DECLARE_COLUMN_PRESET(PAGEFAULTSDELTA,   70,  FALSE)
    DECLARE_COLUMN_PRESET(VIRTUALMEMORYSIZE, 70,  FALSE)
    DECLARE_COLUMN_PRESET(PAGEDPOOL,         70,  FALSE)
    DECLARE_COLUMN_PRESET(NONPAGEDPOOL,      70,  FALSE)
    DECLARE_COLUMN_PRESET(BASEPRIORITY,      60,  FALSE)
    DECLARE_COLUMN_PRESET(HANDLECOUNT,       60,  FALSE)
    DECLARE_COLUMN_PRESET(THREADCOUNT,       60,  FALSE)
    DECLARE_COLUMN_PRESET(USEROBJECTS,       60,  FALSE)
    DECLARE_COLUMN_PRESET(GDIOBJECTS,        60,  FALSE)
    DECLARE_COLUMN_PRESET(IOREADS,           70,  FALSE)
    DECLARE_COLUMN_PRESET(IOWRITES,          70,  FALSE)
    DECLARE_COLUMN_PRESET(IOOTHER,           70,  FALSE)
    DECLARE_COLUMN_PRESET(IOREADBYTES,       70,  FALSE)
    DECLARE_COLUMN_PRESET(IOWRITEBYTES,      70,  FALSE)
    DECLARE_COLUMN_PRESET(IOOTHERBYTES,      70,  FALSE)
};

static int InsertColumn(int nCol, LPCWSTR lpszColumnHeading, int nFormat, int nWidth, int nSubItem);
INT_PTR CALLBACK ColumnsDialogWndProc(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);

void AddColumns(void)
{
    LRESULT size;
    WCHAR szTemp[256];
    UINT n = 0;

    for (n = 0; n < COLUMN_NMAX; n++) 
    {
        if (TaskManagerSettings.Columns[n]) 
        {
            LoadString(hInst, ColumnPresets[n].dwIdsName, szTemp, NUMBER_OF_ITEMS_IN_ARRAY(szTemp));
            InsertColumn(n, szTemp, LVCFMT_LEFT, TaskManagerSettings.ColumnSizeArray[n], -1);
        }
    }

    size = SendMessage(hProcessPageHeaderCtrl, HDM_GETITEMCOUNT, 0, 0);
    SendMessage(hProcessPageHeaderCtrl, HDM_SETORDERARRAY, (WPARAM) size, (LPARAM) &TaskManagerSettings.ColumnOrderArray);

    UpdateColumnDataHints();
}

static int InsertColumn(int nCol, LPCWSTR lpszColumnHeading, int nFormat, int nWidth, int nSubItem)
{
    LVCOLUMN  column;

    column.mask = LVCF_TEXT|LVCF_FMT;
    column.pszText = (LPWSTR)lpszColumnHeading;
    column.fmt = nFormat;

    if (nWidth != -1)
    {
        column.mask |= LVCF_WIDTH;
        column.cx = nWidth;
    }

    if (nSubItem != -1)
    {
        column.mask |= LVCF_SUBITEM;
        column.iSubItem = nSubItem;
    }

    return ListView_InsertColumn(hProcessPageListCtrl, nCol, &column);
}

void SaveColumnSettings(void)
{
    HDITEM        hditem;
    int           i, n;
    WCHAR         text[MAX_PATH];
    WCHAR         szTemp[256];
    LRESULT       size;

    /* Reset column data */
    for (i = 0; i < COLUMN_NMAX; i++) 
    {
        TaskManagerSettings.ColumnOrderArray[i] = i;
        TaskManagerSettings.Columns[i] = FALSE;
        TaskManagerSettings.ColumnSizeArray[i] = ColumnPresets[i].size;
    }

    /* Get header order */
    size = SendMessage(hProcessPageHeaderCtrl, HDM_GETITEMCOUNT, 0, 0);
    SendMessage(hProcessPageHeaderCtrl, HDM_GETORDERARRAY, (WPARAM)size, (LPARAM) &TaskManagerSettings.ColumnOrderArray);

    /* Get visible columns */
    for (i = 0; i < size; i++) 
    {
        memset(&hditem, 0, sizeof(HDITEM));

        hditem.mask = HDI_TEXT|HDI_WIDTH;
        hditem.pszText = text;
        hditem.cchTextMax = MAX_PATH;

        SendMessage(hProcessPageHeaderCtrl, HDM_GETITEM, i, (LPARAM) &hditem);

        for (n = 0; n < COLUMN_NMAX; n++) 
        {
            LoadString(hInst, ColumnPresets[n].dwIdsName, szTemp, sizeof(szTemp)/sizeof(WCHAR));
            
            if (wcsicmp(text, szTemp) == 0)
            {
                TaskManagerSettings.Columns[n] = TRUE;
                TaskManagerSettings.ColumnSizeArray[n] = hditem.cxy;
            }
        }
    }
}

void ProcessPage_OnViewSelectColumns(void)
{
    INT i = 0;

    if (DialogBox(hInst, MAKEINTRESOURCE(IDD_COLUMNS_DIALOG), hMainWnd, ColumnsDialogWndProc) == IDOK)
    {
        for (i = Header_GetItemCount(hProcessPageHeaderCtrl)-1; i >= 0; i--)
        {
            ListView_DeleteColumn(hProcessPageListCtrl, i);
        }

        for (i = 0; i < COLUMN_NMAX; i++) 
        {
            TaskManagerSettings.ColumnOrderArray[i] = i;
            TaskManagerSettings.ColumnSizeArray[i] = ColumnPresets[i].size;
        }

        AddColumns();
    }
}

INT_PTR CALLBACK ColumnsDialogWndProc(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    unsigned int i;

    switch (message)
    {
    case WM_INITDIALOG:

        for (i = 0; i < COLUMN_NMAX; i++) 
        {
            if (TaskManagerSettings.Columns[i])
                SendMessage(GetDlgItem(hDlg, ColumnPresets[i].dwIdcCtrl), BM_SETCHECK, BST_CHECKED, 0);
        }
        return TRUE;

    case WM_COMMAND:

        if (LOWORD(wParam) == IDCANCEL)
        {
            EndDialog(hDlg, LOWORD(wParam));
            return TRUE;
        }

        if (LOWORD(wParam) == IDOK)
        {
            for (i = 0; i < COLUMN_NMAX; i++)
                TaskManagerSettings.Columns[i] = (BOOL)SendMessage(GetDlgItem(hDlg, ColumnPresets[i].dwIdcCtrl), BM_GETCHECK, 0, 0);

            EndDialog(hDlg, LOWORD(wParam));
            return TRUE;
        }

        break;
    }

    return 0;
}

void UpdateColumnDataHints(void)
{
    HDITEM hditem;
    WCHAR text[MAX_PATH];
    ULONG Index;
    WCHAR szTemp[256];
    UINT i = 0;

    for (Index = 0; Index<(ULONG)SendMessage(hProcessPageHeaderCtrl, HDM_GETITEMCOUNT, 0, 0); Index++)
    {
        memset(&hditem, 0, sizeof(HDITEM));

        hditem.mask = HDI_TEXT;
        hditem.pszText = text;
        hditem.cchTextMax = MAX_PATH;

        SendMessage(hProcessPageHeaderCtrl, HDM_GETITEM, Index, (LPARAM) &hditem);

        for (i = 0; i < COLUMN_NMAX; i++) 
        {
            LoadString(hInst, ColumnPresets[i].dwIdsName, szTemp, NUMBER_OF_ITEMS_IN_ARRAY(szTemp));
            
            if (_wcsicmp(text, szTemp) == 0)
                ColumnDataHints[Index] = i;
        }
    }
}