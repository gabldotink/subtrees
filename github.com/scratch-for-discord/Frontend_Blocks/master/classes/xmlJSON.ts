
export enum FieldType {
    Num,
    Str,
    Bool
}


export interface xmlJsonData {
    type: string,
    value: any,
    fieldType?: FieldType, //auto generated
    shadow?: boolean //defaults to false
}
export interface JSONField {
    [key: string]: any;
}
export interface JSONblock {
    kind: string,
    type: string,
    fields?: JSONField,
}
export class XmlJSON {
    data: xmlJsonData[]
    blockName: string
    constructor(block: string) {
        this.blockName = block
        this.data = []
    }
    AddNumberField(name: string, value: number, shadow?: boolean): XmlJSON {
        this.data.push({
            type: name,
            value: value,
            fieldType: FieldType.Num,
            shadow: shadow,
        })
        return this
    }
    AddStringField(name: string, value: number, shadow?: boolean): XmlJSON {
        this.data.push({
            type: name,
            value: value,
            fieldType: FieldType.Str,
            shadow: shadow,
        })
        return this
    }
    AddBoolField(name: string, value: number, shadow?: boolean): XmlJSON {
        this.data.push({
            type: name,
            value: value,
            fieldType: FieldType.Bool,
            shadow: shadow,
        })
        return this
    }
    JSON(): any {
        let baseJson: JSONblock = {
            kind: "block",
            type: this.blockName,
            fields: {}
        }
        for (let i=0; i<this.data.length; i++) {
            let field = this.data[i]
            // @ts-ignore
            baseJson.fields[field.type] = field.value
        }
        return baseJson
    }
    XML(): string {
        let baseString1 = `<block type="${this.blockName}">`
        let secondString1 = "</block>"
        //
        for (let i=0; i<this.data.length; i++) {
           let field = this.data[i]
            baseString1 += `<field name="${field.type}">${field.value}</field>`
        }
        return baseString1 + secondString1
    }
}