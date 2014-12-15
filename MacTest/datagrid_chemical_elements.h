//
//  datagrid_chemical_elements.h
//  GacOSX
//
//  Created by Robert Bu on 12/15/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_datagrid_chemical_elements_h
#define GacOSX_datagrid_chemical_elements_h

#include "gac_include.h"

struct ElementElectron
{
    static const wchar_t* RegexEec;
    
    vint        level;
    wchar_t     type;
    vint        typeOrder;
    vint        count;
    
    static vint Compare(const ElementElectron& a, const ElementElectron& b)
    {
        vint result=0;
        if(result==0) result=a.level-b.level;
        if(result==0) result=a.typeOrder-b.typeOrder;
        if(result==0) result=a.count-b.count;
        return result;
    }
    
    static void Parse(const vl::regex::Regex& regexEec, vint order, const WString& electron, vint& notationOrder, WString& notationName, List<ElementElectron>& ecs)
    {
        if(order<=2)
        {
            notationOrder=0;
            notationName=L"";
        }
        else if(order<=10)
        {
            notationOrder=2;
            notationName=L"[He]";
        }
        else if(order<=18)
        {
            notationOrder=10;
            notationName=L"[Ne]";
        }
        else if(order<=36)
        {
            notationOrder=18;
            notationName=L"[Ar]";
        }
        else if(order<=54)
        {
            notationOrder=36;
            notationName=L"[Kr]";
        }
        else if(order<=86)
        {
            notationOrder=54;
            notationName=L"[Xe]";
        }
        else
        {
            notationOrder=86;
            notationName=L"[Rn]";
        }
        
        ecs.Clear();
        vl::regex::RegexMatch::List matches;
        regexEec.Search(electron, matches);
        FOREACH(Ptr<vl::regex::RegexMatch>, match, matches)
        {
            ElementElectron ec;
            ec.level=wtoi(match->Groups()[L"level"].Get(0).Value());
            ec.type=match->Groups()[L"type"].Get(0).Value()[0];
            ec.count=wtoi(match->Groups()[L"count"].Get(0).Value());
            ec.typeOrder=-1;
            
            switch(ec.type)
            {
                case L's': ec.typeOrder=0; break;
                case L'p': ec.typeOrder=1; break;
                case L'd': ec.typeOrder=2; break;
                case L'f': ec.typeOrder=3; break;
            }
            
            ecs.Add(ec);
        }
        
        SortLambda(&ecs[0], ecs.Count(), &Compare);
    }
    
    WString ToString()
    {
        return itow(level)+type+itow(count);
    }
};

struct ElementElectronConfiguration
{
    vint                                        nobleGasNotationOrder;
    WString                                     nobleGasNotationName;
    List<ElementElectron>                     electrons;
    
    WString ToString()
    {
        WString ecsLabel=nobleGasNotationName;
        FOREACH(ElementElectron, ec, electrons)
        {
            ecsLabel+=L" "+ec.ToString();
        }
        return ecsLabel;
    }
};

struct ElementData
{
    vint        order;
    WString     symbol;
    WString     chinese;
    WString     english;
    double      weight;
    WString     valence;
    WString     electron;
    Ptr<ElementElectronConfiguration>         ecs;
    
    static WString Partition(const wchar_t*& reading)
    {
        const wchar_t* next=wcschr(reading, L'\t');
        if(!next)
        {
            next=reading+wcslen(reading);
        }
        WString text(reading, (vint)(next-reading));
        reading=*next?next+1:next;
        return text;
    }
    
    static ElementData Parse(const WString& text, const vl::regex::Regex& regexEec)
    {
        ElementData data;
        const wchar_t* reading=text.Buffer();
        data.order=wtoi(Partition(reading));
        data.symbol=Partition(reading);
        data.chinese=Partition(reading);
        data.weight=wtof(Partition(reading));
        data.electron=Partition(reading);
        data.valence=Partition(reading);
        data.english=Partition(reading);
        
        data.ecs=new ElementElectronConfiguration;
        ElementElectron::Parse(regexEec, data.order, data.electron, data.ecs->nobleGasNotationOrder, data.ecs->nobleGasNotationName, data.ecs->electrons);
        return data;
    }
};

struct ElementElectronDataRenderer;

class ElementElectronDataVisualizer: public list::DataVisualizerBase
{
public:
    typedef list::DataVisualizerFactory<ElementElectronDataVisualizer>  Factory;
    
protected:
    GuiBoundsComposition*           composition;
    ElementElectronDataRenderer*    renderer;
    
    
    GuiBoundsComposition* CreateBoundsCompositionInternal(GuiBoundsComposition* decoratedComposition);
    
public:
    ElementElectronDataVisualizer();
    
    void BeforeVisualizerCell(list::IDataProvider* dataProvider, vint row, vint column);
    void ShowGraph(list::StrongTypedDataProvider<ElementData>* dataProvider, vint row);
    
};

/***********************************************************************
 Column provider for making the radioactive element names red and bold
 ***********************************************************************/

// Inheriting from StrongTypedFieldColumnProvider enable the column provide to read the data from a specified member variable in a class.
class ElementRadioactiveColumnProvider : public list::StrongTypedFieldColumnProvider<ElementData, WString>
{
public:
    ElementRadioactiveColumnProvider(list::StrongTypedDataProvider<ElementData>* dataProvider, WString ElementData::* field)
    :StrongTypedFieldColumnProvider(dataProvider, field)
    {
    }
    
    void VisualizeCell(vint row, list::IDataVisualizer* dataVisualizer)
    {
        StrongTypedFieldColumnProvider::VisualizeCell(row, dataVisualizer);
        ElementData data;
        dataProvider->GetRowData(row, data);
        
        // If the displaying element is radioactive
        if(data.order==43 || data.order==61 || data.order>=83)
        {
            // Get the text element from the data visualizer.
            // The reason that we know there is a ListViewSubColumnDataVisualizer in the data visualizer is that,
            // we explicitly use this data visualizer for all columns using this column provider
            // in the constructor of the DataProvider class below.
            GuiSolidLabelElement* text=dataVisualizer->GetVisualizer<list::ListViewSubColumnDataVisualizer>()->GetTextElement();
            text->SetColor(Color(255, 0, 0));
            
            FontProperties font=text->GetFont();
            font.bold=true;
            text->SetFont(font);
        }
    }
};

/***********************************************************************
 Column provider for showing the electron configuration for both text and graph
 ***********************************************************************/

// Inheriting from StrongTypedColumnProvider but not StrongTypedFieldColumnProvider because
// we don't directly display the ElementData::electron in the data grid control.
class ElementElectronColumnProvider : public list::StrongTypedColumnProvider<ElementData, WString>
{
protected:
    
    void GetCellData(const ElementData& rowData, WString& cellData)
    {
        // Here is how to display the text more professional, instead of displaying ElementData::electron directly.
        // When constructing an ElementData object using ElementData::Parse,
        // the ecs member will be constructed from ElementData::electron.
        cellData=rowData.ecs->ToString();
    }
    public:
    ElementElectronColumnProvider(list::StrongTypedDataProvider<ElementData>* dataProvider)
    :StrongTypedColumnProvider(dataProvider)
    {
    }

    void VisualizeCell(vint row, list::IDataVisualizer* dataVisualizer)override
    {
        StrongTypedColumnProvider::VisualizeCell(row, dataVisualizer);

        // If we are display this cell using ElementElectronDataVisualizer,
        // we call ShowGraph to fill the data.
        // The ShowGraph function is not predefined.
        // This pattern is very useful for exchanging complext data between column provider and data visualizer.
        ElementElectronDataVisualizer* eedVisualizer=dataVisualizer->GetVisualizer<ElementElectronDataVisualizer>();
        if(eedVisualizer)
        {
            eedVisualizer->ShowGraph(dataProvider, row);
        }
    }
};

/***********************************************************************
 Data source for chemical elements
 ***********************************************************************/

class DataProvider : public list::StrongTypedDataProvider<ElementData>
{
protected:
    List<ElementData>                         elements;
    Ptr<list::IDataVisualizerFactory>         mainFactory;
    Ptr<list::IDataVisualizerFactory>         subFactory;
    Ptr<list::IDataVisualizerFactory>         eecFactory;
public:
    DataProvider()
    {
        // mainFactory will draw a data cell with a border, an image (not used in this demo), and a black text.
        mainFactory=new list::CellBorderDataVisualizer::Factory(new list::ListViewMainColumnDataVisualizer::Factory);
        // subFactory will draw a data cell with a border and a gray text. The style of the text can be changed.
        subFactory=new list::CellBorderDataVisualizer::Factory(new list::ListViewSubColumnDataVisualizer::Factory);
        // eecFactory draw the "element electron configuration" graph using the data from this data provider.
        eecFactory=new list::CellBorderDataVisualizer::Factory(new ElementElectronDataVisualizer::Factory);
        
        // Order column using mainFactory. Clicking this column will sort the data.
        AddSortableFieldColumn(L"Order", &ElementData::order)
        ->SetVisualizerFactory(mainFactory);
        
        // Symbol column using subFactory. The ElementRadioactiveColumnProvider will change the text style to be red and bold for radioactive elements
        AddStrongTypedColumn<WString>(L"Symbol", new ElementRadioactiveColumnProvider(this, &ElementData::symbol))
        ->SetVisualizerFactory(subFactory);
        
        // Chinese column as the previous one
        AddStrongTypedColumn<WString>(L"Chinese", new ElementRadioactiveColumnProvider(this, &ElementData::chinese))
        ->SetVisualizerFactory(subFactory);
        
        // English column as the previous one
        AddStrongTypedColumn<WString>(L"English", new ElementRadioactiveColumnProvider(this, &ElementData::english))
        ->SetVisualizerFactory(subFactory)
        ->SetSize(120);
        
        // Weight column using subFactory. Clicking this column will sort the data.
        AddSortableFieldColumn(L"Weight", &ElementData::weight)
        ->SetVisualizerFactory(subFactory);
        
        // Valence column using subFactory
        AddFieldColumn(L"Valence", &ElementData::valence)
        ->SetVisualizerFactory(subFactory)
        ->SetSize(100);
        
        // Electron column using subFactory. The ElementElectronColumnProvider will display the data in ElementData::electron using a professional style.
        AddStrongTypedColumn<WString>(L"Electron", new ElementElectronColumnProvider(this))
        ->SetVisualizerFactory(subFactory)
        ->SetSize(160);
        
        // Electron Graph column using eecFactory.
        AddStrongTypedColumn<WString>(L"Electron Graph", new ElementElectronColumnProvider(this))
        ->SetVisualizerFactory(eecFactory)
        ->SetSize(160);
        
        vl::stream::FileStream fileStream(GetApplication()->GetExecutableFolder()+L"/Contents/Resources/Chemical.txt", vl::stream::FileStream::ReadOnly);
        vl::stream::BomDecoder decoder;
        vl::stream::DecoderStream decoderStream(fileStream, decoder);
        vl::stream::StreamReader reader(decoderStream);
        
        vl::regex::Regex regexEec(ElementElectron::RegexEec);
        while(!reader.IsEnd())
        {
            WString line=reader.ReadLine();
            elements.Add(ElementData::Parse(line, regexEec));
        }
    }
    
    void GetRowData(vint row, ElementData& rowData)override
    {
        rowData=elements[row];
    }

    vint GetRowCount()override
    {
        return elements.Count();
    }
};

/***********************************************************************
 ChemicalElementWindow
 ***********************************************************************/

class ChemicalElementWindow : public GuiWindow
{
private:
    GuiVirtualDataGrid*                 dataGrid;
    
public:
    ChemicalElementWindow()
    :GuiWindow(GetCurrentTheme()->CreateWindowStyle())
    {
        this->SetText(L"Controls.DataGrid.ChemicalElements");
        
        dataGrid=new GuiVirtualDataGrid(GetCurrentTheme()->CreateListViewStyle(), new DataProvider);
        dataGrid->GetBoundsComposition()->SetAlignmentToParent(Margin(5, 5, 5, 5));
        dataGrid->SetHorizontalAlwaysVisible(false);
        dataGrid->SetVerticalAlwaysVisible(false);
        AddChild(dataGrid);
        
        // set the preferred minimum client size
        this->GetBoundsComposition()->SetPreferredMinSize(Size(900, 600));
        // call this to calculate the size immediately if any indirect content in the table changes
        // so that the window can calcaulte its correct size before calling the MoveToScreenCenter()
        this->ForceCalculateSizeImmediately();
        // move to the screen center
        this->MoveToScreenCenter();
    }
};

#endif
